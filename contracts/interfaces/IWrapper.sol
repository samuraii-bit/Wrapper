// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IWrapper {
    function getPythPrice() external view returns(int64);
    function getChainlinkPrice() external view returns(uint256);
    function getTwapPrice(address token, uint256 amountIn) external returns (uint256 amountOut);
    function addLiquidity(uint256 _myTokenAmount, uint256 _stableCoinAmount) external; 
}
