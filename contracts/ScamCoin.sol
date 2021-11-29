//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ScamCoin is ERC20 {

    constructor(uint256 initialSupply) ERC20("ScamCoin", "SKM"){
        _mint(msg.sender, initialSupply);
    }

}
