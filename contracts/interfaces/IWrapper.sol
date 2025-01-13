// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IWrapper {
    event AddLiquidity(
        address _token0, 
        address _token1, 
        uint256 _token0AmountDesired, 
        uint256 _token1AmountDesired, 
        uint256 _token0Min,
        uint256 _token1Min,
        address _to, 
        uint256 _deadline
    );

    function getPythPrice() external view returns(uint256);
    function getChainlinkPrice() external view returns(uint256);
    function getTwapPrice(address token, uint256 amountIn) external view returns (uint256 amountOut);
    function addLiquidity(uint256 _myTokenAmount, uint256 _stableCoinAmount) external; 
}
