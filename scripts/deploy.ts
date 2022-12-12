import { ethers } from "hardhat";

const decimal = 10 ** 4;

async function main() {
  const Factory = await ethers.getContractFactory("Factory");
  // replace your params
  const fac = await Factory.deploy()

  await fac.deployed();

  console.log(`deploy Factory success, address is`, fac.address);
  process.exit(0);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
