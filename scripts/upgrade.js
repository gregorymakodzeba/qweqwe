const { ethers, upgrades } = require('hardhat');

async function main() {
  try{    
    const Presale = await ethers.getContractFactory('Presale');
    console.log('Upgrading Presale...');
    await upgrades.upgradeProxy('0xa1017feA9605c03A1f9b3CF6875dd58Ab314BF5D', Presale);
    console.log('Presale upgraded');
  }catch(err){
    console.log(err);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
