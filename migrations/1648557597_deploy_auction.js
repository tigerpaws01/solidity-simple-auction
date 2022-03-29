var Auction = artifacts.require("Auction"); 
var Storage = artifacts.require("Storage");

module.exports = function(_deployer) {
  _deployer.deploy(Auction, 
    "0x17627Fe6a19f98fc3FB1980b9a6ECF813c776D4b",
    22, 500,
    20,
    "");

  _deployer.deploy(Storage);
};

