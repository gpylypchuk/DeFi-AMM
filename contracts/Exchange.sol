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

    function getAmount(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) private pure returns(uint256) {
        require(inputReserve > 0 && outputReserve > 0, "Not Enough Reserves.");
        // X * Y = K
        // X = inputReserve
        // Y = outputReserve
        // (x - xy) * (y - dy) = k
        uint256 outputAmount = (inputAmount * outputReserve) / (inputReserve + inputAmount);
        return (outputAmount);
    }

    function getTokenAmount (uint256 _ethSold) public view returns (uint256) {
        require(_ethSold > 0, "dale pa");
        uint256 tokenReserve = getReserve();
        return getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    function getEthAmount (uint256 _tokenSold) public view returns (uint256) {
        require(_tokenSold > 0, "Not Enought Ether.");
        uint256 tokenReserve = getReserve();
        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

}