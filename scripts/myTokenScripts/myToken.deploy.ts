import { writeFileSync } from 'fs';
import { ethers, network } from "hardhat";
import {name, symbol, decimals, initialSupply} from "./tokenInit";
import path = require('path');
import { HardhatEthersHelpers } from 'hardhat/types';

async function main() {

    const users = await ethers.getSigners()
    const MyFirstToken = await ethers.getContractFactory("MyFirstToken");
    const myFirstToken = await MyFirstToken.deploy("MyFirstToken", "MFT", 18, ethers.parseUnits("10000000000", decimals));

    await myFirstToken.waitForDeployment();
    console.log(`Contract deployed to: ${myFirstToken.target}`);
    
    await myFirstToken.connect(users[0]).mint(users[0].address, ethers.parseUnits("100000", 18));

    const addresses = {contractAddress: myFirstToken.target, ownerAddress: myFirstToken.deploymentTransaction()?.from};
    const filePath = path.join(__dirname, "addresses.json");
    writeFileSync(filePath, JSON.stringify(addresses, null, 2));
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});