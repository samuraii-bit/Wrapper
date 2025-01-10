import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    hardhat: {
      forking: {
        url: process.env.MAINNET_FORK_ALCHEMY_URL,
        blockNumber: 21494386,
      }
    }
  }
  
};

export default config;
