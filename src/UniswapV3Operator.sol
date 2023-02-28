// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { Bookkeeper } from "src/Bookkeeper.sol";
import { Registra } from "src/Registra.sol";
import { IWithdrawERC20Callback } from "src/interfaces/callbacks/IWithdrawERC20Callback.sol";
import { IWithdrawERC20sCallback } from "src/interfaces/callbacks/IWithdrawERC20sCallback.sol";

import { IUniswapV3Operator } from "src/interfaces/operator/IUniswapV3Operator.sol";
import { ISwapRouter } from "src/interfaces/external/uniswap/ISwapRouter.sol";
import { INonfungiblePositionManager } from "src/interfaces/external/uniswap/INonfungiblePositionManager.sol";
import { TransferHelper } from "./utils/TransferHelper.sol";

contract UniswapV3Operator is IUniswapV3Operator, IWithdrawERC20Callback, IWithdrawERC20sCallback {
    INonfungiblePositionManager public immutable s_NPM;
    ISwapRouter public immutable s_SWAPROUTER;

    Registra public immutable s_REGISTRA;
    Bookkeeper public immutable s_BOOKKEEPER;

    enum Function {
        None,
        AddLiquidity,
        SwapExactInputSingle
    }

    Function private runningFunc;

    constructor(address registra, address bookkeeper, address npm, address swapRouter) {
        s_REGISTRA = Registra(registra);
        s_BOOKKEEPER = Bookkeeper(bookkeeper);

        s_NPM = INonfungiblePositionManager(npm);
        s_SWAPROUTER = ISwapRouter(swapRouter);
    }

    modifier requireOwnerOperator(uint positionId) {
        address owner = s_BOOKKEEPER.ownerOf(positionId);
        require(msg.sender == owner || s_BOOKKEEPER.isApprovedForAll(owner, msg.sender), "require owner or operator.");
        _;
    }

    modifier requireBookkeeper() {
        require(msg.sender == address(s_BOOKKEEPER), "only called by bookkeeper.");
        _;
    }

    modifier runFunc(Function func) {
        require(func != Function.None, "no function given.");
        require(runningFunc == Function.None, "other function is running.");
        runningFunc = func;
        _;
        runningFunc = Function.None;
    }

    function addLiquidity(AddLiquidityParams calldata params)
        external
        override
        requireOwnerOperator(params.positionId)
        runFunc(Function.AddLiquidity)
        returns (uint tokenId, uint128 liquidity, uint amount0, uint amount1)
    {
        bytes memory callbackParams = abi.encode(params);
        bytes memory callbackResult;

        address[] memory tokens = new address[](2);
        uint[] memory amounts = new uint[](2);

        tokens[0] = params.token0;
        tokens[1] = params.token1;

        amounts[0] = params.amount0Desired;
        amounts[1] = params.amount1Desired;

        callbackResult = s_BOOKKEEPER.withdrawERC20s(params.positionId, tokens, amounts, address(this), callbackParams);

        (tokenId, liquidity, amount0, amount1) = abi.decode(callbackResult, (uint, uint128, uint, uint));
    }

    function execAddLiquidity(AddLiquidityParams memory params) internal returns (bytes memory) {
        TransferHelper.safeApprove(params.token0, address(s_NPM), params.amount0Desired);
        TransferHelper.safeApprove(params.token1, address(s_NPM), params.amount1Desired);

        INonfungiblePositionManager.MintParams memory params1 = INonfungiblePositionManager.MintParams({
            token0: params.token0,
            token1: params.token1,
            fee: params.fee,
            tickLower: params.tickLower,
            tickUpper: params.tickUpper,
            amount0Desired: params.amount0Desired,
            amount1Desired: params.amount1Desired,
            amount0Min: params.amount0Min,
            amount1Min: params.amount1Min,
            recipient: address(s_BOOKKEEPER),
            deadline: block.timestamp
        });

        (uint tokenId, uint128 liquidity, uint amount0, uint amount1) = s_NPM.mint(params1);

        s_BOOKKEEPER.depositERC721(params.positionId, address(s_NPM), tokenId);

        if (amount0 < params.amount0Desired) {
            TransferHelper.safeApprove(params.token0, address(s_NPM), 0);

            uint unspend = params.amount0Desired - amount0;
            TransferHelper.safeTransfer(params.token0, address(s_BOOKKEEPER), unspend);
            s_BOOKKEEPER.depositERC20(params.positionId, params.token0, unspend);
        }

        if (amount1 < params.amount1Desired) {
            uint unspend = params.amount1Desired - amount1;
            TransferHelper.safeTransfer(params.token1, address(s_BOOKKEEPER), unspend);
            s_BOOKKEEPER.depositERC20(params.positionId, params.token1, unspend);
        }

        return abi.encode(tokenId, liquidity, amount0, amount1);
    }

    function swapExactInputSingle(SwapExactInputSingleParams calldata params)
        external
        override
        requireOwnerOperator(params.positionId)
        runFunc(Function.SwapExactInputSingle)
        returns (uint amountOut)
    {
        bytes memory result = s_BOOKKEEPER.withdrawERC20(
            params.positionId, params.tokenIn, params.amountIn, address(this), abi.encode(params)
        );

        (amountOut) = abi.decode(result, (uint));
    }

    function execSwapExactInputSingle(SwapExactInputSingleParams memory params) internal returns (bytes memory) {
        TransferHelper.safeApprove(params.tokenIn, address(s_SWAPROUTER), params.amountIn);

        ISwapRouter.ExactInputSingleParams memory params1 = ISwapRouter.ExactInputSingleParams({
            tokenIn: params.tokenIn,
            tokenOut: params.tokenOut,
            fee: params.fee,
            recipient: address(s_BOOKKEEPER),
            deadline: block.timestamp,
            amountIn: params.amountIn,
            amountOutMinimum: params.amountOutMinimum,
            sqrtPriceLimitX96: params.sqrtPriceLimitX96
        });

        uint amountOut = s_SWAPROUTER.exactInputSingle(params1);
        s_BOOKKEEPER.depositERC20(params.positionId, params.tokenOut, amountOut);

        return abi.encode(amountOut);
    }

    function withdrawERC20Callback(
        uint, /* positionId */
        address, /* token */
        uint, /* amount */
        address, /* recipient */
        bytes calldata data
    ) external override requireBookkeeper returns (bytes memory result) {
        Function func = runningFunc;

        if (func == Function.SwapExactInputSingle) {
            SwapExactInputSingleParams memory params;
            (params) = abi.decode(data, (SwapExactInputSingleParams));
            return execSwapExactInputSingle(params);
        }

        revert("unknown callback function.");
    }

    function withdrawERC20sCallback(
        uint, /* positionId */
        address[] calldata, /* tokens */
        uint[] calldata, /* amounts */
        address, /* recipient */
        bytes calldata data
    ) external override requireBookkeeper returns (bytes memory result) {
        Function func = runningFunc;

        if (func == Function.AddLiquidity) {
            AddLiquidityParams memory params;
            (params) = abi.decode(data, (AddLiquidityParams));
            return execAddLiquidity(params);
        }

        revert("unknown callback function.");
    }
}
