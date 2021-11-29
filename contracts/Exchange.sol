//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange {

    address public tokenAddress;

    constructor(address _token){
        require(_token != address(0), "Token Invalido");
        tokenAddress = _token;
    }

    function addLiquidity(uint256 _tokenAmount) public payable {
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), _tokenAmount);
    }

    function getReserve() public view returns (uint256) {
        return ERC20(tokenAddress).balanceOf(address(this));
    }

    function getPrice(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) private pure returns(uint256) {
        // X * Y = K
        // X = inputReserve
        // Y = outputReserve
        // (x - xy) * ()
        return (inputAmount);
    }

}