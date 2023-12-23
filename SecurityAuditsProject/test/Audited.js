// Import required modules
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StorageVictimAudited", function () {
    // Declare variables
    let storageVictim;
    let caller;
    let callerAmount;

    beforeEach(async () => {
        // Get the contract factory for StorageVictimAudited
        const StorageVictimAudited = await ethers.getContractFactory(
            "StorageVictimAudited"
        );

        // Deploy the StorageVictimAudited contract
        storageVictim = await StorageVictimAudited.deploy();

        // Wait for the contract to be deployed
        await storageVictim.deployed();

        // Get the signer
        [caller] = await ethers.getSigners();

        // Set an initial amount to store
        callerAmount = 100;
    });

    it("should store and retrieve the amount correctly", async function () {
        // Store the initial amount
        await storageVictim.store(callerAmount);

        // Retrieve the stored amount
        const [user, _amount] = await storageVictim.getStore();

        // Ensure the retrieved values are correct
        expect(user).to.equal(caller.address);
        expect(_amount).to.equal(callerAmount);
    });

    it("should update the stored amount correctly", async function () {
        // Store the initial amount
        await storageVictim.store(callerAmount);

        // Update the amount to store
        callerAmount = 200;

        // Update the stored amount
        await storageVictim.store(callerAmount);

        // Retrieve the updated amount
        const [user, amount] = await storageVictim.getStore();

        // Ensure the retrieved values are correct
        expect(user).to.equal(caller.address);
        expect(amount).to.equal(callerAmount);
    });
});