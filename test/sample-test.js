const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

let myTokenContract = null;
let dealerContract = null;

describe("deploy contracts", async function () {
  it("Deploy MyToken", async function () {
    const [deployer, tokenOwner] = await ethers.getSigners();
    const MyToken = await ethers.getContractFactory("MyToken");
    myTokenContract = await MyToken.deploy("Token", "TK", tokenOwner.address);
    expect(myTokenContract.address.length).to.not.equal(0);
  });

  it("Deploy Dealer", async function () {
    const [deployer, tokenOwner, adminOne] = await ethers.getSigners();
    const dealer = await ethers.getContractFactory("Dealer");
    dealerContract = await dealer.deploy(adminOne.address);
    expect(dealerContract.address.length).to.not.equal(0);
  });
});

describe("sell order", async function () {
  it("When customer sell customer balance decreased + dealer balance increase", async function () {
    const [deployer, tokenOwner] = await ethers.getSigners();
    const prevCusBalance = await myTokenContract
      .connect(tokenOwner)
      .balanceOf(tokenOwner.address);
    const prevTokenOwnerBalance = await myTokenContract
      .connect(tokenOwner)
      .balanceOf(dealerContract.address);
    await myTokenContract
      .connect(tokenOwner)
      .approve(dealerContract.address, 10);
    await dealerContract
      .connect(tokenOwner)
      .createSellOrder(myTokenContract.address, 10, 5);
    const newCusBalance = await myTokenContract
      .connect(tokenOwner)
      .balanceOf(tokenOwner.address);
    const newTokenOwnerBalance = await myTokenContract
      .connect(tokenOwner)
      .balanceOf(dealerContract.address);
    assert(prevCusBalance.sub(newCusBalance).eq(ethers.BigNumber.from(10)));
    assert(
      newTokenOwnerBalance
        .sub(prevTokenOwnerBalance)
        .eq(ethers.BigNumber.from(10))
    );
  });

  it("admin can match sell order", async function () {
    const [deployer, tokenOwner, adminOne] = await ethers.getSigners();
    await myTokenContract
      .connect(tokenOwner)
      .approve(dealerContract.address, 10);
    const sellOrderId = await dealerContract
      .connect(tokenOwner)
      .createSellOrder(myTokenContract.address, 10, 5);
    // must use event
    // console.log(sellOrderId);
    // assert(sellOrderId.length > 0);
    // const buyOrderId = await dealerContract
    //   .connect(adminOne)
    //   .matchOrder(sellOrderId);
    // assert(buyOrderId.length > 0);
  });
});
