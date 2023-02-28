// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

interface IUniswapV3Operator {
    struct AddLiquidityParams {
        uint positionId;
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint amount0Desired;
        uint amount1Desired;
        uint amount0Min;
        uint amount1Min;
    }

    function addLiquidity(AddLiquidityParams calldata params)
        external
        returns (uint tokenId, uint128 liquidity, uint amount0, uint amount1);

    struct SwapExactInputSingleParams {
        uint positionId;
        address tokenIn;
        address tokenOut;
        uint24 fee;
        uint amountIn;
        uint amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function swapExactInputSingle(SwapExactInputSingleParams calldata params) external returns (uint amountOut);
}
