pragma solidity ^0.4.23;

contract DominantAssuranceContract {
    address owner;
    uint256 deadline;
    uint256 goal;
    uint8 percentagePayoff;
    mapping(address => uint256) public balanceOf;
    uint256 totalPledges;

    constructor(uint256 numberOfDays, uint256 _goal, uint8 _percentagePayoff) public payable {
        owner = msg.sender;
        deadline = now + (numberOfDays * 1 days);
        goal = _goal;
        percentagePayoff = _percentagePayoff;
        balanceOf[msg.sender] = msg.value;
    }

    function pledge(uint256 amount) public payable {
        require(now < deadline, "The campaign is over.");
        require(msg.value == amount, "The amount is incorrect.");
        require(msg.sender != owner, "The owner cannot pledge.");

        uint256 payoff = amount * percentagePayoff / 100;
        if (payoff > balanceOf[owner]) {
            payoff = balanceOf[owner];
        }
        balanceOf[owner] -= payoff;
        balanceOf[msg.sender] += amount+payoff;
        totalPledges += amount;
    }

    function claimFunds() public {
        require(now >= deadline, "The campaign is not over.");
        require(totalPledges >= goal, "The funding goal was not met.");
        require(msg.sender == owner, "Only the owner may claim funds.");

        msg.sender.transfer(address(this).balance);
    }

    function getRefund() public {
        require(now >= deadline, "The campaign is still active.");
        require(totalPledges < goal, "Funding goal was met.");

        uint256 amount = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}
