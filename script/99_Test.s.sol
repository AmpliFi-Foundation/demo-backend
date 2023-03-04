// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import "forge-std/Script.sol";

import "@prb-math/SD59x18.sol" as SD59x18;
import { UD60x18, sqrt } from "@prb-math/UD60x18.sol";

import { BaseScript1 } from "./02_BaseScript1.s.sol";

import { Registra } from "src/Registra.sol";
import { PUD } from "src/PUD.sol";
import { Bookkeeper } from "src/Bookkeeper.sol";

import { IUniswapV3Operator } from "src/interfaces/operator/IUniswapV3Operator.sol";

import { MathHelper } from "src/utils/MathHelper.sol";
import { UniswapV3Math } from "src/utils/UniswapV3Math.sol";

import { IERC20 } from "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

contract Swap is BaseScript1 {
    function run() external {

        Bookkeeper bk = Bookkeeper(bookkeeper);
        IUniswapV3Operator op = IUniswapV3Operator(operator);

        vm.startBroadcast(anvilPk1);

        bk.setApprovalForAll(address(op), true);

        IUniswapV3Operator.SwapExactInputSingleParams memory params = IUniswapV3Operator.SwapExactInputSingleParams({
            positionId: 1,
            tokenIn: PUDAddr,
            tokenOut: USDC,
            fee: 500,
            amountIn: 100_000_000,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: uint160(5 * UniswapV3Math.Q96 / 10)
        });

        uint amountOut = op.swapExactInputSingle(params);

        vm.stopBroadcast();
        console.logUint(amountOut);
    }
}

contract Test1 is BaseScript1 {
    function run() external view {
        SD59x18.SD59x18 multipler = SD59x18.UNIT.add(SD59x18.wrap(-1e9));
        UD60x18 t = sqrt(UD60x18.wrap(1e6));
        uint160 f = toFixPoint96(t);
        UD60x18 t1 = fromFixPoint96(f-1);

        console.logUint(UD60x18.unwrap(t));
        console.logUint(f);
        console.logUint(UD60x18.unwrap(t1));
    }
}
