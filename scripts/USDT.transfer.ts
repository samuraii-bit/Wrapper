import { ethers, network } from "hardhat";
import path = require('path');

async function main() {

    const whaleRawAddress = "0xf977814e90da44bfa03b6295a0616a897441acec";
    await network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [whaleRawAddress],
      });

    const users = await ethers.getSigners()
    
    const usdtAddress = "0xdac17f958d2ee523a2206206994597c13d831ec7";
    const usdt = await ethers.getContractAt("IERC20", usdtAddress);
    const amount = ethers.parseUnits("1000", 6);
    
    const whale = await ethers.getSigner(whaleRawAddress);
    
    const balanceBefore = await usdt.balanceOf(users[0].address);
    console.log(`${users[0].address} (users[0]) balance of usdt before transfer:`, balanceBefore);
    
    await usdt.connect(whale).transfer(users[0].address, amount);
    console.log(`${amount} USDT transferred to ${users[0].address}`);

    const balanceAfter = await usdt.balanceOf(users[0].address);
    console.log(`${users[0].address} (users[0]) balance of usdt after transfer:`, balanceAfter);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});