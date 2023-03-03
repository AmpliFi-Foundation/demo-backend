// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import "forge-std/Script.sol";

import { BaseScript1 } from "./02_BaseScript1.s.sol";
import { PUD } from "src/PUD.sol";

import { IUniswapV3Factory } from "src/interfaces/external/uniswap/IUniswapV3Factory.sol";
import { IUniswapV3Pool } from "src/interfaces/external/uniswap/IUniswapV3Pool.sol";
import { INonfungiblePositionManager } from "src/interfaces/external/uniswap/INonfungiblePositionManager.sol";

import { IERC20 } from "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

contract ProvideLiquidity is BaseScript1 {
    function mint()
        internal
        broadcast(anvilPk2)
        returns (uint, uint128, uint, uint)
    {
        PUD pud = PUD(PUDAddr);
        INonfungiblePositionManager NPM = INonfungiblePositionManager(uniswapNPM);

        uint24 fee = 500;
        uint amount = 1_000_000e6; // 1 Million of PUD or USDC

        pud.testnet_mint(anvilAddr2, amount);
        pud.approve(uniswapNPM, type(uint).max);

        IERC20(USDC).approve(address(NPM), type(uint).max);

        address poolAddr = IUniswapV3Factory(uniswapFactory).getPool(PUDAddr, USDC, fee);
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddr);
        (, int24 tick,,,,,) = pool.slot0();

        (address token0, address token1) = PUDAddr < USDC ? (PUDAddr, USDC) : (USDC, PUDAddr);

        INonfungiblePositionManager.MintParams memory params;

        params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: tick - 1000,
            tickUpper: tick + 1000,
            amount0Desired: amount,
            amount1Desired: amount,
            amount0Min: 0,
            amount1Min: 0,
            recipient: anvilAddr2,
            deadline: block.timestamp + 1e6
        });

        return NPM.mint(params);
    }

    function run() external {
        (uint tokenId, uint128 liquidity, uint amountA, uint amountB) = mint();

        console.log("Uniswap NFT: %d", tokenId);
        console.log("  Liquidity: %d", uint(liquidity));
        console.log("        PUD: %d", amountA);
        console.log("       USDC: %d", amountB);
    }
}
