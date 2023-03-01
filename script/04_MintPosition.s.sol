// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import "forge-std/Script.sol";

import { BaseScript1 } from "./02_BaseScript1.s.sol";
import { Bookkeeper } from "src/Bookkeeper.sol";
import { IERC20 } from "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

contract MintPosition is BaseScript1 {
    function run() external broadcast(anvilPk1) {
        Bookkeeper bk = Bookkeeper(bookkeeper);

        uint positionId = bk.mint(anvilAddr1);

        uint amount = 5e9; // 5000 USDC
        IERC20(USDC).transfer(bookkeeper, amount);
        bk.depositERC20(positionId, USDC, amount);

        console.log("Amplifi Position: %d", positionId);
    }
}