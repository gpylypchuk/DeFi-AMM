//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Exchange.sol";

contract Registry {

    mapping(address => address) public tokenToExchange;

    function getExchange(address _tokenAddress) public view returns (address) {
        return tokenToExchange[_tokenAddress];
    }

    function createExchange(address _tokenAddress) public returns (address) {
        require(_tokenAddress != address(0), "Invalid token address");
        require(tokenToExchange[_tokenAddress] == address(0), "Exchange already exists");
        // Deploys Exchange contract with the token address contract (constructor).
        Exchange exchange = new Exchange(_tokenAddress);
        tokenToExchange[_tokenAddress] = address(exchange);
        return address(exchange);
    }

}