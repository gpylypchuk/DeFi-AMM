const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const { provider } = waffle;

describe("Exchange", function () {
  beforeEach(async function() {
    const Token = await ethers.getContractFactory("ScamCoin");
    token = await Token.deploy(1000);
    await token.deployed();

    const Exchange = await ethers.getContractFactory("Exchange");
    exchange = await Exchange.deploy(token.address);
    await exchange.deployed();
  });

  it("Adds Liquidity", async function() {
    await token.approve(exchange.address, 200);
    await exchange.addLiquidity(200, { value: 100 });

    expect(provider.getBalance(exchange.address).to.equal(100));
    expect(exchange.getReserve().to.equal(200));

  })
})

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
