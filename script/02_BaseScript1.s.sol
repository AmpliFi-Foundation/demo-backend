// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { BaseScript0 } from "./00_BaseScript0.s.sol";

contract BaseScript1 is BaseScript0 {
    address public registra = vm.envAddress("AMP_REGISTRA");
    address public bookkeeper = vm.envAddress("AMP_BOOKKEEPER");
    address public PUDAddr = vm.envAddress("AMP_PUD");
    address public treasurer = vm.envAddress("AMP_TREASURER");
    address public operator = vm.envAddress("AMP_UNISWAP_OPERATOR");
    address public PoolPUDUSDC = vm.envAddress("PUD_USDC_POOL");
}
