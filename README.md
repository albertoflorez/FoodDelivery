# FoodDelivery

This is the example code repository for the Food Delivery Web3.0 app.

## Setup

You can clone this repo and get going right away.

Just make sure to:
- run `npm install` to set up all the dependencies (hardhat, ethers, etc.)
- rename `.env-example` to `.env` and then fill in the environment variables with your own info
- set up an Alchemy account [here](https://alchemy.com)
- set up a [Metamask](https://metamask.io/download.html) wallet with [fake testnet ether](https://sepoliafaucet.com/)

And then you should be able to:
- run `npx hardhat run scripts/deploy.js` if you only want to depoy the contracts to the Sepolia testnet
- run `npx hardhat run scripts/simulateRight.js` to simulate a good delivery procedure.
- run `npx hardhat run scripts/simulateWrong.js` to simulate a bod delivery procedure.
- run `npx hardhat verify --network sepolia <your deplooyment address> 'add arguments depending on the contract'` to verify your contract on Etherscan

