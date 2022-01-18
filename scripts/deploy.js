const { ethers } = require("hardhat");

async function main() {
  // We get the contract to deploy
  const [deployer, tokenOwner] = await ethers.getSigners();
  const MyToken = await ethers.getContractFactory("MyToken");
  const myToken = await MyToken.deploy("Token", "TK", tokenOwner.address);

  const Dealer = await ethers.getContractFactory("Dealer");
  const dealer = await Dealer.deploy();
  console.log(
    "dealerContract balance is",
    await myToken.connect(deployer).balanceOf(dealer.address)
  );
  await myToken.connect(tokenOwner).approve(dealer.address, 100);
  await dealer.connect(tokenOwner).createSellOrder(myToken.address, 10, 5);
  console.log(
    "dealerContract balance is",
    await myToken.connect(deployer).balanceOf(dealer.address)
  );
  // console.log(
  //   "addr1 balance is",
  //   await myToken.connect(addr1).balanceOf(addr1.address)
  // );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
