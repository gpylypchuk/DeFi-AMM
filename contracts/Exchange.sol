//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Registry.sol";

contract Exchange is ERC20 {

    address public tokenAddress;
    address public registryAddress;

    constructor(address _token) ERC20("Exchange LP SKM-ETH", "LP") {
        // Check if the token is a ERC20 (You can check more!).
        require(_token != address(0), "Invalid Token Address");
        tokenAddress = _token;
        registryAddress = msg.sender;
    }

    function addLiquidity(uint256 _tokenAmount) 
    public
    payable 
    returns (uint256) {
        uint256 mintedTokens;
        if(totalSupply() == 0) {
            mintedTokens = address(this).balance;
        } else {
            uint ethReserve = address(this).balance - msg.value;
            uint tokenReserve = getReserve();
            uint256 correctTokenAmount = (msg.value * tokenReserve) / ethReserve;
            require(_tokenAmount >= correctTokenAmount, "Not enough tokens");
            mintedTokens = (totalSupply() * msg.value) / ethReserve;
        }
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), _tokenAmount);
        _mint(msg.sender, mintedTokens);
        return mintedTokens;
    }

    function removeLiquidity(uint256 _amount) public returns (uint256, uint256) {
        require(_amount <= 0, "Invalid amount");
        uint256 ethAmount = (address(this).balance * _amount) / totalSupply();
        uint256 tokenAmount = (getReserve() * _amount) / totalSupply();
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
        return(ethAmount, tokenAmount);
    }

    function getReserve() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function _getAmount(
        uint256 inputAmount, 
        uint256 inputReserve, 
        uint256 outputReserve
        ) private pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "Invalid Reserves.");
        /*
            X = inputReserve
            Y = outputReserve 
            X * Y = K
            (x - dx) * (y - dy) = k
        
            uint256 outputAmount = (inputAmount * outputReserve) / 
                    (inputReserve + inputAmount);
            return (outputAmount);
        */
        uint fee = 99;
        uint256 inputAmountWithFee = inputAmount * fee;
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = inputReserve * 100 + inputAmountWithFee;
        return numerator / denominator;
    }

    function getTokenAmount(uint256 _ethSold) public view returns (uint256) {
        require(_ethSold > 0, "Ether amount must be greater than 0.");
        uint256 tokenReserve = getReserve();
        return _getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    function getEthAmount(uint256 _tokenSold) public view returns (uint256) {
        require(_tokenSold > 0, "Not Enough Ether.");
        uint256 tokenReserve = getReserve();
        return _getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

    function ethToTokenSwap(uint256 _minTokens) public payable {
        uint256 tokenReserve = getReserve();
        uint256 tokensBought = _getAmount(
            msg.value, 
            address(this).balance - msg.value, 
            tokenReserve
            );
        require(tokensBought >= _minTokens, "The tokens you will receive are not enough to your minimun exchange amount.");
        IERC20(tokenAddress).transfer(msg.sender, tokensBought);
    }

    function ethToToken(uint256 _minTokens, address _recipient) private {
        uint256 tokenReserve = getReserve();
        uint256 tokensBought = _getAmount(
            msg.value, 
            address(this).balance - msg.value, 
            tokenReserve
            );
        require(tokensBought >= _minTokens, "The tokens you will receive are not enough to your minimun exchange amount.");
        IERC20(tokenAddress).transfer(_recipient, tokensBought);
    }

    function tokenToEthSwap(uint256 _minTokens) public payable {
        ethToToken(_minTokens, msg.sender);
    }

    function ethToTokenTransfer(uint256 _minTokens, address _recipient) public payable {
        ethToToken(_minTokens, _recipient);
    }

    // Swap token to token!
    function tokenToTokenSwap(
        uint256 _tokensSold, 
        uint256 _minTokensBought, 
        address _tokenAddress
        ) public {
        /*
            This is the SKM exchange
            I want to buy DAI paying SKM
            Which is the DAI exchange?
        */
        address exchangeAddress = Registry(registryAddress).getExchange(_tokenAddress);
        require(exchangeAddress != address(this), "Invalid Exchange Address");
        require(exchangeAddress != address(0), "Invalid Exchange Address");
        uint256 tokenReserve = getReserve();
        uint256 ethBought = _getAmount(_tokensSold, tokenReserve, address(this).balance);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _tokensSold);
        Exchange(exchangeAddress).ethToTokenTransfer{value: ethBought}(_minTokensBought, msg.sender);
    }    

}