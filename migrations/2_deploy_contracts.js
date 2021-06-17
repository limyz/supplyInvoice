// migrations/2_deploy.js
var supplyInvoice = artifacts.require("./supplyInvoice.sol");

module.exports = function(deployer, network, accounts){
  deployer.deploy(supplyInvoice);
};

