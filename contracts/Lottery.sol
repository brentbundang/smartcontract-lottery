// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";


contract Lottery {
    address payable[] public players;
    uint256 public usdEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;

    function enter() public payable{
        //require();
        //50USD minimum
        players.push(msg.sender);    
    }

    constructor(address _priceFeed) public{
         usdEntryFee = 50 * (10**18); //Expressed in wei
         ethUsdPriceFeed = AggregatorV3Interface(_priceFeed);
    }

    function getEntranceFee() public view returns (uint256){
        // Store the enterance fee
        (, int256 price, , , , ) = ethUsdPriceFeed.latestRoundData;
        uint256 adjustedPrice = uint256(price) * 10 ** 10; //18 decmial places
        // 50, 2000 eth
        // 50/2000
        // 50 * 100000 / 2000
        uint256 costToEnter = (usdEntryFee * 10 ** 18) / price;
        return costToEnter;

    }
    function startLottery() public {}
    function endLottery() public {}
}