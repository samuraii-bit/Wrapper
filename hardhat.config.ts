import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.6.6",
      },
      {
        version: "0.8.0",
        settings: {},
      },
      {
        version: "0.8.28",
        settings: {},
      },
    ],
  },
  networks: {
    hardhat: {
      chainId: 1337,
      forking: {
        url: process.env.MAINNET_FORK_ALCHEMY_URL,
        blockNumber: 21494386,
      }
    }
  }
  
};

export default config;
