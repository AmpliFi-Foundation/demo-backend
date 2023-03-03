// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import "forge-std/Script.sol";
import { ud } from "prb-math/UD60x18.sol";
import { SD59x18 } from "prb-math/SD59x18.sol";

import { BaseScript1 } from "./02_BaseScript1.s.sol";

import { TokenInfo } from "src/structs/TokenInfo.sol";
import { TokenType } from "src/structs/TokenType.sol";
import { Registra } from "src/Registra.sol";

contract InitRegistra is BaseScript1 {
    function run() external broadcast(anvilPk2) {
        Registra reg = Registra(registra);

        setInterestRate(reg);
        setPenaltyRate(reg);
        setTokenInfos(reg);
    }

    function setInterestRate(Registra registra) internal {
        registra.setInterestRate(SD59x18.wrap(1e6));
    }

    function setPenaltyRate(Registra registra) internal { }

    function setTokenInfos(Registra reg) internal {
        TokenInfo memory pudInf = TokenInfo({
            enabled: true,
            type_: TokenType.ERC20,
            priceOracle: PoolPUDUSDC,
            liquidationRatio: ud(0)
        });
        reg.setTokenInfo(PUDAddr, pudInf);

        TokenInfo memory usdcInf =
            TokenInfo({enabled: true, type_: TokenType.ERC20, priceOracle: address(0), liquidationRatio: ud(0.05e18)});
        reg.setTokenInfo(USDC, usdcInf);

        TokenInfo memory daiInf = TokenInfo({
            enabled: true,
            type_: TokenType.ERC20,
            priceOracle: vm.parseAddress("0x6c6Bc977E13Df9b0de53b251522280BB72383700"),
            liquidationRatio: ud(0.05e18)
        });
        reg.setTokenInfo(DAI, daiInf);

        TokenInfo memory weth9Inf = TokenInfo({
            enabled: true,
            type_: TokenType.ERC20,
            priceOracle: vm.parseAddress("0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640"),
            liquidationRatio: ud(0.25e18)
        });
        reg.setTokenInfo(WETH9, weth9Inf);

        TokenInfo memory uniswapNFT =
            TokenInfo({enabled: true, type_: TokenType.ERC721, priceOracle: address(0), liquidationRatio: ud(0)});
        reg.setTokenInfo(uniswapNPM, uniswapNFT);
    }
}
