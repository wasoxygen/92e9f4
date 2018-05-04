pragma solidity ^0.4.23;

//smart contract for incentivized fundraiser
//sponor creates a contract and provides seed funding
//each supporter can create a pledge
//each pledge is increased by the bonusPercent amount, from seed funding
//if the goal is met, all pledges (inclusive of bonus) are sent to fundraiser destination
//if the goal is not met, supporters can collect their pledges with bonus

//the fundraiser contract
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

    //submit a pledge (in the amount of the transaction value, in wei)
    function pledge() public payable {
        pledge(msg.value);
    }

    //submit a pledge (passing in the value of the transaction, in wei)
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

    //once the deadline has passed, if the total pledges meet the goal, send all pledges and bonus to fundraising destination
    function consummate() public {
        require(now >= deadline, "The campaign is not over yet!");
        require(totalPledges >= goal, "Alas, the funding goal was not met. Use getRefund() to recover pledges and bonus.");
        destination.transfer(address(this).balance);
    }

    //if the deadline has passed and the goal was not met, allow the supporter to retrieve the pledge plus bonus
    function getRefund() public {
        require(now >= deadline, "The campaign is not over yet!");
        require(totalPledges < goal, "Good news, the  goal was met. Use consummate() to transfer pledges to the destination.");

        uint256 amount = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
    
    //one year after the deadline, forward unclaimed pledges plus bonus to fundraising destination
    function collectAbandonedPledges() public {
        require(now >= deadline + 365 days, "Pledges cannot be collected until 365 days after the deadline.");
        destination.transfer(address(this).balance);
    }
    
    //show total amount of all pledges (exclusive of bonus, in wei)
    function getTotalPledges() public view returns (uint256) {
        return totalPledges;
    }
    
    //get days left before deadline
    function getDaysLeft() public view returns(uint256) {
        uint256 daysLeft = (deadline - now) / (60 * 60 * 24);
        return daysLeft;
    }

}
