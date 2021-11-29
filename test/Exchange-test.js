const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const { provider } = waffle;

const amountA = ethers.utils.parseEther("")

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

    expect(await provider.getBalance(exchange.address)).to.equal(100);
    expect(await exchange.getReserve()).to.equal(200);

  })

  it("devuelve la cantidad correcta de ethers", async() => {
    await token.approve(exchange.address, 1000);
    await exchange.addLiquidity(1000, { value: 50 });

    let tokenOut = await exchange.getTokenAmount(1);
    expect(ethers.utils.formatEther(tokenOut)).to.equal(980.3921569);
  })
})
