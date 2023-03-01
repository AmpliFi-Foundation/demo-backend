// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import "forge-std/Script.sol";

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
        address usdc = vm.envAddress("USDC");
        address dai = vm.envAddress("DAI");

        Bookkeeper bk = Bookkeeper(vm.envAddress("AMP_BOOKKEEPER"));
        IUniswapV3Operator operator = IUniswapV3Operator(vm.envAddress("AMP_UNISWAP_OPERATOR"));

        vm.startBroadcast(vm.envUint("ANVIL_PK_1"));
        bk.setApprovalForAll(address(this), true);
        bk.setApprovalForAll(address(operator), true);

        IUniswapV3Operator.SwapExactInputSingleParams memory params = IUniswapV3Operator.SwapExactInputSingleParams({
            positionId: 1,
            tokenIn: usdc,
            tokenOut: dai,
            fee: 100,
            amountIn: 500000000,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 1 << 96
        });

        uint amountOut = operator.swapExactInputSingle(params);
        vm.stopBroadcast();

        console.logBool(bk.isApprovedForAll(vm.envAddress("ANVIL_ADDR_1"), address(this)));
        console.logUint(amountOut);
    }
}

contract Test1 is BaseScript1 {
    function run() external {
        vm.startPrank(vm.parseAddress("0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8"));
        IERC20(DAI).transfer(anvilAddr3, 100 ether);
        vm.stopPrank();
        console.logUint(IERC20(DAI).balanceOf(anvilAddr3));
    }
}
