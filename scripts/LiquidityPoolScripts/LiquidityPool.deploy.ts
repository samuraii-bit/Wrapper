import { writeFileSync } from 'fs';
import { ethers } from "hardhat";
import path = require('path');

async function main() {
    const users = await ethers.getSigners();
    const router = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const LiquidityPool = await ethers.getContractFactory("LiquidityPool");
    const liquidityPool = await LiquidityPool.deploy(ethers.getAddress(router));

    await liquidityPool.waitForDeployment();

    await liquidityPool.connect(users[0]).addLiquidity(
        ethers.getAddress("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"), 
        ethers.getAddress("0x01D4648B896F53183d652C02619c226727477C82"),
        ethers.parseUnits("100", 18),
        ethers.parseUnits("100", 6),
        ethers.parseUnits("1", 18),
        ethers.parseUnits("1", 18),
        users[0].address,
        Math.floor((Date.now() / 1000)) + 300,
    );

    console.log(`Contract deployed to: ${liquidityPool.target}`);
    const addresses = {contractAddress: liquidityPool.target, ownerAddress: liquidityPool.deploymentTransaction()?.from};
    const filePath = path.join(__dirname, "addresses.json");
    writeFileSync(filePath, JSON.stringify(addresses, null, 2));
    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});