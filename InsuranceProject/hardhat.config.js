// imports
require("@nomiclabs/hardhat-waffle");
require('dotenv').config();

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337
    },
    // set mumbai testnet for deploying smart contract
    mumbai: {
      url: "https://holy-omniscient-meme.matic-testnet.discover.quiknode.pro/844a88e15be1e30d1f855bc750b2401cc57b3089/",
      accounts: ["9673488150c05380c2d245a4b7926252132489ecc9f19fd3513e926993cce2d1"],
    }
  },
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};



