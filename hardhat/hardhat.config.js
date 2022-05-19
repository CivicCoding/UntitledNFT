/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.1",
  path: {
    sources: "./contracts",
    test: "./tests",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};
