// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract WalletInsurance {
    // Address of the contract owner
    address public owner;

    // Amount to be insured
    uint256 public insuredAmount;

    // Token amount
    uint256 public token;

    // Flag indicating if the contract is insured
    bool public insured;

    // Duration for basic insurance
    uint256 constant private BasicInsuranceDuration = 90 days;

    // Policy for basic insurance
    uint256 constant private BasicPolicy = 1e9;

    // Duration for standard insurance
    uint256 constant private StandardInsuranceDuration = 180 days;

    // Policy for standard insurance
    uint256 constant private StandardPolicy = 1e8;

    // Duration of insurance coverage
    uint256 public insuranceDuration;

    // Mapping to store the balance of each address
    mapping(address => uint256) public balance;

    // Mapping to store the token balance of each address
    mapping(address => uint256) public tokenBalance;

    // Event emitted when a payment is received
    event PaymentReceived(address indexed payer, uint256 amount);

    // Event emitted when an insurance claim is made
    event Claimed(address indexed claimant, uint256 amount);

    constructor(uint256 _insuredAmount) {
        // Set the contract owner as the transaction sender
        owner = msg.sender;
        // Set the insured amount
        insuredAmount = _insuredAmount;
    }

    // Function for paying insurance
    function payInsurance() external payable {
        // Check if the caller is already insured
        require(!insured, "You are already insured.");

        // Check if the amount sent is sufficient
        require(msg.value >= insuredAmount, "The amount provided is not valid.");

        // Check if the payment is allowed at this time
        require(block.timestamp > insuranceDuration, "You are unable to make a payment at this time.");

        // Add the payment amount to the owner's balance
        balance[owner] += msg.value;

        // Calculate insurance duration and token based on the amount paid
        if (msg.value < 1 ether) {
            // Set the insurance duration for basic insurance
            insuranceDuration = block.timestamp + BasicInsuranceDuration;

            // Calculate the token amount for basic insurance
            token = (msg.value * 4 * insuranceDuration) / BasicPolicy;
        } else if (msg.value >= 1 ether) {
            // Set the insurance duration for standard insurance
            insuranceDuration = block.timestamp + StandardInsuranceDuration;

            // Calculate the token amount for standard insurance
            token = (msg.value * 9 * insuranceDuration) / StandardPolicy;
        }

        // Set the insured flag to true
        insured = true;

        // Emit the payment received event
        emit PaymentReceived(msg.sender, msg.value);
    }

    // Modifier to restrict access to only the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner, "This action can only be performed by the owner of the contract.");
        _;
    }

    // Function for claiming insurance
    function claimInsurance() external payable onlyOwner() {
        // Check if the caller has insurance coverage
        require(insured, "You do not have insurance coverage.");

        // Check if the insurance has expired
        require(block.timestamp > insuranceDuration, "Your insurance is still valid and has not expired.");

        // Check if the insurance payment has been made
        require(balance[owner] != 0, "The insurance payment has not been made.");

        // Set the insured flag to false
        insured = false;

        // Add the token amount to the owner's token balance
        tokenBalance[owner] += token;

        // Send the contract's balance to the owner
        (bool sent, ) = (owner).call{value: address(this).balance}("");

        // Check if the transfer of Ether was successful
        require(sent, "The attempt to send Ether has failed.");

        // Emit the insurance claimed event
        emit Claimed(msg.sender, address(this).balance);
    }

    // Function to get the balance of the caller
    function getBalance() external view returns (uint256) {
        return balance[msg.sender];
    }

    // Function to get the token balance of the caller
    function getTokenBalance() external view returns (uint256) {
        return tokenBalance[msg.sender];
    }
}
