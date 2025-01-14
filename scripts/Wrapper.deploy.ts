import { ethers } from "hardhat";
import { writeFileSync } from 'fs';
import { join } from 'path';
import { uniswapV2RouterAddress, 
        factoryAddress, 
        myTokenAddress, 
        stableCoinAddress, 
        chainlinkOracleAddress, 
        pythOracleAddress, 
        btcUsdPriceId
        } from "./contractsAddresses/constructorNeeded";

const contractsInfoPath = "./scripts/contractsAddresses/"

async function main() {
    const WrapperFactory = await ethers.getContractFactory("Wrapper");
    const Wrapper = await WrapperFactory.deploy(
        ethers.getAddress("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"), 
        ethers.getAddress("0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"),
        ethers.getAddress("0x64386BC53c213F23C6960d3e080139A0f9Ef1733"),
        ethers.getAddress("0xdac17f958d2ee523a2206206994597c13d831ec7"),
        ethers.getAddress("0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c"),
        ethers.getAddress("0x4305FB66699C3B2702D4d05CF36551390A4c69C6"),
        ethers.getBytes("0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43")
    );

    await Wrapper.waitForDeployment();

    console.log(`Contract deployed to: ${Wrapper.target}`);
    const addresses = {DAOContractAddress: Wrapper.target, ownerAddress: Wrapper.deploymentTransaction()?.from};
    writeFileSync(join(contractsInfoPath, "Wrapper.json"), JSON.stringify(addresses, null, 2));
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});