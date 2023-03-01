// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import "forge-std/Script.sol";
import { wrap } from "prb-math/UD60x18.sol";

import { TokenInfo } from "src/structs/TokenInfo.sol";
import { TokenType } from "src/structs/TokenType.sol";
import { Registra } from "src/Registra.sol";

contract InitRegistra is Script {
    function run() external {
        Registra registra = Registra(vm.envAddress("AMP_REGISTRA"));

        vm.startBroadcast();

        setInterestRate(registra);
        setPenaltyRate(registra);
        setTokenInfos(registra);

        vm.stopBroadcast();
    }

    function setInterestRate(Registra registra) internal {
        // registra.setInterestRate(interestRate);
    }

    function setPenaltyRate(Registra registra) internal { }

    function setTokenInfos(Registra registra) internal {
        address pud = vm.envAddress("AMP_PUD");
        address pudUsdcPool = vm.envAddress("PUD_USDC_POOL");
        TokenInfo memory pudInf =
            TokenInfo({enabled: true, type_: TokenType.ERC20, priceOracle: pudUsdcPool, liquidationRatio: wrap(0)});
        registra.setTokenInfo(pud, pudInf);

        address usdc = vm.envAddress("USDC");
        TokenInfo memory usdcInf =
            TokenInfo({enabled: true, type_: TokenType.ERC20, priceOracle: address(0), liquidationRatio: wrap(0.05e18)});
        registra.setTokenInfo(usdc, usdcInf);

        address dai = vm.envAddress("DAI");
        TokenInfo memory daiInf = TokenInfo({
            enabled: true,
            type_: TokenType.ERC20,
            priceOracle: vm.parseAddress("0x6c6Bc977E13Df9b0de53b251522280BB72383700"),
            liquidationRatio: wrap(0.05e18)
        });
        registra.setTokenInfo(dai, daiInf);

        address weth9 = vm.envAddress("WETH9");
        TokenInfo memory weth9Inf = TokenInfo({
            enabled: true,
            type_: TokenType.ERC20,
            priceOracle: vm.parseAddress("0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640"),
            liquidationRatio: wrap(0.25e18)
        });
        registra.setTokenInfo(weth9, weth9Inf);

        address npm = vm.envAddress("UNISWAP_V3_NPM");
        TokenInfo memory uniswapNFT =
            TokenInfo({enabled: true, type_: TokenType.ERC721, priceOracle: address(0), liquidationRatio: wrap(0)});
        registra.setTokenInfo(npm, uniswapNFT);
    }
}
