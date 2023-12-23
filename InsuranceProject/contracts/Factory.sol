// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./WalletInsurance.sol";
import "./CollateralProtection.sol";

contract InsuranceFactory {
    // Mapping to store user addresses and their corresponding insurance contracts
    mapping(address => address) private userInsuranceContracts;

    // Mapping to store user addresses and their corresponding wallet contracts
    mapping(address => address) private userWalletContract;

    // Event emitted when a wallet insurance contract is created for a user
    event WalletInsuranceCreated(address indexed user, address walletInsurance);

    // Event emitted when a collateral protection contract is created for a user
    event CollateralProtectionCreated(address indexed user, address collateralProtection);

    /**
     * @dev Creates a wallet insurance contract for the caller.
     * @param _insuredAmount The amount to be insured in the wallet insurance contract.
     */
    function createWalletInsurance(uint256 _insuredAmount) external {
        // Check if the user already has an existing insurance contract
        require(userWalletContract[msg.sender] == address(0), "You already have an existing insurance contract.");

        // Create a new WalletInsurance contract with the specified insured amount
        WalletInsurance walletInsurance = new WalletInsurance(_insuredAmount);

        // Associate the WalletInsurance contract with the user by storing its address in the userWalletContract mapping
        userWalletContract[msg.sender] = address(walletInsurance);

        // Emit an event to indicate the creation of the WalletInsurance contract
        emit WalletInsuranceCreated(msg.sender, address(walletInsurance));
    }

    /**
     * @dev Returns the address of the wallet contract associated with the caller.
     * @return The address of the caller's associated wallet contract.
     */
    function getUserWalletContract() external view returns (address) {
        // Return the wallet contract address associated with the caller's address
        return userWalletContract[msg.sender];
    }

    /**
     * @dev Creates a collateral protection contract for the caller.
     */
    function createCollateralProtection() external {
        // Check if the user already has an existing insurance contract
        require(userInsuranceContracts[msg.sender] == address(0), "You already have an existing insurance contract.");

        // Create a new CollateralProtection contract
        CollateralProtection collateralProtection = new CollateralProtection();

        // Associate the CollateralProtection contract with the user by storing its address in the userInsuranceContracts mapping
        userInsuranceContracts[msg.sender] = address(collateralProtection);

        // Emit an event to indicate the creation of the CollateralProtection contract
        emit CollateralProtectionCreated(msg.sender, address(collateralProtection));
    }

    /**
     * @dev Returns the address of the insurance contract associated with the caller.
     * @return The address of the caller's associated insurance contract.
     */
    function getUserInsuranceContracts() external view returns (address) {
        // Return the insurance contract address associated with the caller's address
        return userInsuranceContracts[msg.sender];
    }
}
