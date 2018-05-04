pragma solidity ^0.4.23;

contract Fundski_2018 {
    address sponsor;
    address destination;
    uint256 deadline;
    uint256 goal;
    uint8 bonusPercent;
    mapping(address => uint256) public balanceOf;
    uint256 totalPledges;
    constructor(uint256 numberOfDays, uint256 _goal, uint8 _bonusPercent, address _destination) public payable {
        sponsor = msg.sender;
        deadline = now + (numberOfDays * 1 days);
        goal = _goal;
        bonusPercent = _bonusPercent;
        balanceOf[msg.sender] = msg.value;
        destination = _destination; //expect 0x5fCc0Ba549683f3211F933997B68c09B6f92E9F4
    }

    function pledge(uint256 amount) public payable {
        require(now < deadline, "Sorry, this campaign is over.");
        require(msg.value == amount, "The amount pledged does not match the amount sent.");
        require(msg.sender != sponsor, "The sponsor cannot pledge.");

        uint256 supporterBonus = amount * bonusPercent / 100;
        if (supporterBonus > balanceOf[sponsor]) {
            supporterBonus = balanceOf[sponsor];
        }
        balanceOf[sponsor] -= supporterBonus;
        balanceOf[msg.sender] += amount+supporterBonus;
        totalPledges += amount;
    }

    function consummate() public {
        require(now >= deadline, "The campaign is not over yet!");
        require(totalPledges >= goal, "Alas, the funding goal was not met. Use getRefund() to recover pledges and bonus.");
        destination.transfer(address(this).balance);
    }

    function getRefund() public {
        require(now >= deadline, "The campaign is not over yet!");
        require(totalPledges < goal, "Good news, the  goal was met. Use consummate() to transfer pledges to the destination.");

        uint256 amount = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
    
    function collectAbandonedPledges() public {
        require(now >= deadline + 365 days, "Pledges cannot be collected until 365 days after the deadline.");
        destination.transfer(address(this).balance);
    }

}
