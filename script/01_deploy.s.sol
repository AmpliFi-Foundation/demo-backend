// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import "forge-std/Script.sol";
import { BaseScript0 } from "./00_BaseScript0.s.sol";

import { Registra } from "src/Registra.sol";
import { PUD } from "src/PUD.sol";
import { Bookkeeper } from "src/Bookkeeper.sol";
import { Treasurer } from "src/Treasurer.sol";
import { UniswapV3Operator } from "src/UniswapV3Operator.sol";

import { UD60x18, sqrt } from "@prb-math/UD60x18.sol";

contract Deploy is BaseScript0 {
    function run() external {
        address steward = vm.parseAddress("0x432d41b6e26005a550Aab06425dfca01f22A0848");
        vm.startBroadcast();
        address registra = address(new Registra(steward));
        PUD pud = new PUD("Amplifi Testnet - PUD", "PUD", registra);
        Bookkeeper bookkeeper = new Bookkeeper("Amplifi NFT", "AMP", registra);
        Treasurer treasurer = new Treasurer(registra, uniswapNPM);
        UniswapV3Operator operator = new UniswapV3Operator(registra, address(bookkeeper), uniswapNPM, uniswapSwapRouter);
        vm.stopBroadcast();

        // pud.initialize();
        // bookkeeper.initialize();
        // treasurer.initialize();

        // uint160 sqrtPriceX96;
        // if (address(pud) < USDC) {
        //     sqrtPriceX96 = toFixPoint96(sqrt(UD60x18.wrap(1e6))); // price is 1e-12
        // } else {
        //     sqrtPriceX96 = toFixPoint96(sqrt(UD60x18.wrap(1e30))); // price is 1e12
        // }

        // address pool = treasurer.createPUDUniswapV3Pool(USDC, sqrtPriceX96, 500);

        string memory file = "env/contracts.env";
        vm.writeFile(file, string.concat("AMP_REGISTRA=", vm.toString(address(registra))));
        vm.writeLine(file, "");
        vm.writeLine(file, string.concat("AMP_BOOKKEEPER=", vm.toString(address(bookkeeper))));
        vm.writeLine(file, string.concat("AMP_PUD=", vm.toString(address(pud))));
        vm.writeLine(file, string.concat("AMP_TREASURER=", vm.toString(address(treasurer))));
        vm.writeLine(file, string.concat("AMP_UNISWAP_OPERATOR=", vm.toString(address(operator))));
        // vm.writeLine(file, string.concat("PUD_USDC_POOL=", vm.toString(address(pool))));
    }
}
