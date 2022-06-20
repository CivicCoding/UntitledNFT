/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
const dotenv = require("dotenv");
dotenv.config();

module.exports = {
  defaultNetwork: "rinkeby",
  solidity: "0.8.1",
  networks:{
    rinkeby:{
      url: process.env.RINKEBY_RPC_URL,
      accounts: [process.env.RINKEBY_PRIVATE_KEY]
    }
  },
  etherscan:{
    apiKey: process.env.RINKEBY_RPC_URL
  },
  path: {
    sources: "./contracts",
    test: "./tests",
    cache: "./cache",
    artifacts: "./artifacts"
  }

};
