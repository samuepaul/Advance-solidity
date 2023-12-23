// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract CollateralProtection {
    // Address of the contract owner
    address public owner;

    // Threshold for collateral
    uint256 public collateralThreshold;

    struct LoanPolicy {
        // Amount of the loan
        uint256 loanAmount;

        // Threshold for collateral associated with the loan
        uint256 collateralThreshold;

        // Duration of the loan
        uint256 loanDuration;

        // Amount owed for the loan
        uint256 loanOwed;

        // Wallet balance associated with the loan
        uint256 wallet;

        // Flag indicating if the loan has been paid
        bool paid;
    }

    // Mapping to track collateral amounts for each borrower
    mapping(address => uint256) public loanCollateral;

    // Mapping to track loan policies for each borrower
    mapping(address => LoanPolicy) public loan;

    // Event emitted when a loan is created
    event LoanCreated(address indexed borrower, uint256 loanAmount, uint256 collateralAmount);

    // Event emitted when collateral is returned
    event CollateralReturned(address indexed borrower, uint256 collateralAmount);

    constructor() {
        owner = tx.origin; // Set the contract owner to the deployer's address
    }

    // Constants for different loan plans and durations

    // Amount for the basic loan plan
    uint256 private constant BasicPlan = 1 ether;

    // Duration for the basic loan plan
    uint256 private constant BasicPlanDuration = 90 days;

    // Amount for the premium loan plan
    uint256 private constant PremiumPlan = 2 ether;

    // Duration for the premium loan plan
    uint256 private constant PremiumPlanDuration = 180 days;

    // Only owner modifier
    modifier onlyOwner() {
        // Only the contract owner can perform this action
        require(msg.sender == owner, "This action can only be performed by the owner of the contract.");
        _;
    }

    // Function to create a loan
    function createLoan(uint256 loanAmount, uint256 collateralAmount) external onlyOwner {
        // Check if the loan amount and collateral amount are greater than zero
        require(loanAmount > 0, "The loan amount should be higher than zero.");
        require(collateralAmount > 0, "The collateral amount needs to exceed zero.");

        // Check if a loan with the same details already exists for the sender
        require(loan[msg.sender].loanAmount == 0, "A loan with the same details already exists.");

        if (loanAmount > BasicPlan) {
            // If the loan amount is greater than the BasicPlan value, create a premium loan with a 20% interest rate
            loan[owner] = LoanPolicy(
                loanAmount,
                collateralAmount,
                block.timestamp + PremiumPlanDuration,
                loanAmount + (loanAmount * 20) / 100,
                0,
                false
            );
        } else if (loanAmount <= BasicPlan) {
            // If the loan amount is less than or equal to the BasicPlan value, create a basic loan with a 10% interest rate
            loan[owner] = LoanPolicy(
                loanAmount,
                collateralAmount,
                block.timestamp + BasicPlanDuration,
                loanAmount + (loanAmount * 10) / 100,
                0,
                false
            );
        }

        // Store the collateral amount for the loan
        loanCollateral[msg.sender] = collateralAmount;

        // Emit a LoanCreated event with the details of the loan created
        emit LoanCreated(msg.sender, loanAmount, collateralAmount);
    }

    // Function to collect the loan
    function collectLoan() external payable {
        // Check if the owner has collateral
        require(loanCollateral[owner] != 0, "There is no collateral associated with your account.");

        // Check if the owner's wallet balance is zero
        require(loan[owner].wallet == 0, "The balance in your wallet must be zero.");

        // Check if the owner's collateral is sufficient based on the loan amount
        require(loan[owner].collateralThreshold >= loan[owner].loanAmount, "The amount of collateral you have is insufficient.");

        // Check if the loan has not been paid yet
        require(!loan[owner].paid, "The loan has not been paid out yet.");

        // Send the loan amount to the owner's address
        (bool sent,) = (owner).call{value: loan[owner].loanAmount}("");
        require(sent, "The attempt to send Ether has failed.");

        // Add the loan amount to the owner's wallet balance
        loan[owner].wallet += loan[owner].loanAmount;
    }

    // Function to pay the loan
    function payLoan() external payable {
        // Check if there is an existing loan available to pay
        require(loan[owner].loanOwed > 0, "There is no loan available to be paid.");

        // Check if the payment amount is sufficient to cover the loan
        require(msg.value >= loan[owner].loanOwed, "The provided amount is not sufficient.");

        // Check if the loan has not been paid yet
        require(!loan[owner].paid, "The loan has not been paid out yet.");

        // Transfer the payment to the contract
        payable(address(this)).transfer(msg.value);

        // Deduct the payment from the loan amount owed
        loan[owner].loanOwed -= msg.value;

        // Claim collateral by setting collateral amount to zero
        loanCollateral[msg.sender] = 0;

        // Emit an event to indicate that collateral has been returned
        emit CollateralReturned(owner, msg.value);
    }

    // Fallback function to receive Ether
    receive() payable external {}
}
