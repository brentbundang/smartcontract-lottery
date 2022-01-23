// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable{
    address payable[] public players;
    address payable public recentWinner;
    uint256 public usdEntryFee;
    uint256 public randomness;
    AggregatorV3Interface internal ethUsdPriceFeed;

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    LOTTERY_STATE public lottery_state;
    uint256 public fee;
    bytes32 public keyhash; //uniquely idenitfy the chainlink VRF node 

    function enter() public payable{
        require(lottery_state == LOTTERY_STATE.OPEN);
        require(msg.value >= getEntranceFee(), "Not enough ETH!");
        //50USD minimum
        players.push(payable(msg.sender));    
    }

    constructor(address _priceFeed, 
    address _vrfCoordinator, 
    address _link, 
    uint256 _fee,
    bytes32 _keyhash)
    

    public VRFConsumerBase(_vrfCoordinator, _link)
    {
         usdEntryFee = 50 * (10**18); //Expressed in wei
         ethUsdPriceFeed = AggregatorV3Interface(_priceFeed);
         lottery_state = LOTTERY_STATE.CLOSED;
         fee = _fee;
         keyhash = _keyhash;
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

    function endLottery() public onlyOwner {
       lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
       requestRandomness(keyhash,fee);  //request/recieve call chainlink
    }

    function fulfillRandomness(bytes32 _requestId, uint _randomness) internal override {
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER, "You aren't there yet!");
        require(_randomness > 0, "random not found");
        uint256 indexOfWinner = _randomness % players.length;
        recentWinner = players[indexOfWinner];
        recentWinner.transfer(address(this).balance);
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
        randomness = _randomness;
    }
}