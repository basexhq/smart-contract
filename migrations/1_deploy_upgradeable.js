const BaseX = artifacts.require('BaseX');
 
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
 
module.exports = async function (deployer) {
  await deployProxy(BaseX, ["0x55A3d9Bd99F286F1817CAFAAB124ddDDFCb0F314" /* factory */, "0x347AfEec4D7fAA853e5a4868C0684D02B9DA1Ce1" /* organisations */ ], { deployer, initializer: 'initializer' });
};