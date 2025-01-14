// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidityPool {
    address private immutable routerAddress;
    IUniswapV2Router02 private immutable router;

    constructor(address _routerAddress) {
        routerAddress = _routerAddress;
        router = IUniswapV2Router02(_routerAddress);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external {

        IERC20(tokenA).approve(routerAddress, amountADesired);
        IERC20(tokenB).approve(routerAddress, amountBDesired);

        router.addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }
}