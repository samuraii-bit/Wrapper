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
        uniswapV2RouterAddress, 
        factoryAddress, 
        myTokenAddress, 
        stableCoinAddress, 
        chainlinkOracleAddress, 
        pythOracleAddress, 
        btcUsdPriceId
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