// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import "forge-std/Script.sol";

import "@prb-math/SD59x18.sol" as SD59x18;
import { UD60x18, sqrt } from "@prb-math/UD60x18.sol";

import { Registra } from "src/Registra.sol";
import { PUD } from "src/PUD.sol";
import { Bookkeeper } from "src/Bookkeeper.sol";

import { IUniswapV3Operator } from "src/interfaces/operator/IUniswapV3Operator.sol";

import { MathHelper } from "src/utils/MathHelper.sol";
import { UniswapV3Math } from "src/utils/UniswapV3Math.sol";

import { IERC20 } from "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

contract Test1 is Script {
    function run() external view {
        console.logUint(10000 ether);
    }
}
