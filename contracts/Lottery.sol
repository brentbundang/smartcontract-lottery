// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable{
    address payable[] public players;
    uint256 public usdEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    LOTTERY_STATE public lottery_state;

    function enter() public payable{
        require(lottery_state == LOTTERY_STATE.OPEN);
        require(msg.value >= getEntranceFee(), "Not enough ETH!");
        //50USD minimum
        players.push(payable(msg.sender));    
    }

    constructor(address _priceFeed){
         usdEntryFee = 50 * (10**18); //Expressed in wei
         ethUsdPriceFeed = AggregatorV3Interface(_priceFeed);
         lottery_state = LOTTERY_STATE.CLOSED;
    }

    function getEntranceFee() public view returns (uint256){
        // Store the enterance fee
        (, int256 price,,,) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10 ** 10; //18 decmial places
        // 50, 2000 eth
        // 50/2000
        // 50 * 100000 / 2000
        uint256 costToEnter = (usdEntryFee * 10 ** 18) / adjustedPrice;
        return costToEnter;
    }

    function startLottery() public onlyOwner {
        require(lottery_state == LOTTERY_STATE.CLOSED, "Didn't start the new lottery yet");
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public {}
}