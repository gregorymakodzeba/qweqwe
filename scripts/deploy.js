const { ethers, upgrades } = require('hardhat');

async function main() {
  try{    
    const Presale = await ethers.getContractFactory('Presale');
    console.log('Deploying Presale...');
    const presale = await upgrades.deployProxy(Presale, [
      [
        '0x4984aefC02674b60D40ef57FAA158140AE69c0a8',
        '0xEC261AaA4A88Ce37671fEa5027b9d3f2f3C3a445'
      ],
      [
        400,
        600
      ],
      '100000000000000000000',
      "1683358947"
    ],
      { initializer: 'initialize'});
    await presale.deployed();
    console.log('presale deployed to:', presale.address);
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
