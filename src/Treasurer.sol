// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { Registra } from "./Registra.sol";
import { TokenInfo } from "./structs/TokenInfo.sol";
import { MathHelper } from "./utils/MathHelper.sol";

import { IUniswapV3Pool } from "src/interfaces/external/uniswap/IUniswapV3Pool.sol";
import { INonfungiblePositionManager } from "src/interfaces/external/uniswap/INonfungiblePositionManager.sol";


contract Treasurer {
    Registra private immutable s_REGISTRA;
    INonfungiblePositionManager public immutable s_NPM;

    address private s_bookkeeper;
    address private s_pud;

    uint256 internal constant Q96 = 0x1000000000000000000000000;

    constructor(address registra, address npm) {
        s_REGISTRA = Registra(registra);
        s_REGISTRA.setTreasurer(address(this));

        s_NPM = INonfungiblePositionManager(npm);
    }

    function initialize() external {
        s_bookkeeper = s_REGISTRA.getBookkeeper();
        s_pud = s_REGISTRA.getPud();
    }

    function priceOfPoolX96(address pool, address token0) internal view returns (uint) {
        if (pool == address(0)) return Q96;

        IUniswapV3Pool v3Pool = IUniswapV3Pool(pool);

        //TODO calculate time weight price from pool.observe
        (uint160 sqrtPriceX96,,,,,,) = v3Pool.slot0();

        uint priceX96 = MathHelper.mulDivRoundUp(sqrtPriceX96, sqrtPriceX96, Q96);

        if (token0 != v3Pool.token0()) {
            priceX96 = MathHelper.mulDivRoundUp(Q96, Q96, priceX96);
        }

        return priceX96;
    }

    function valueOfERC20(address token, uint amount) external view returns (uint) {
        if (token == s_pud) return amount;

        TokenInfo memory tokenInf = s_REGISTRA.tokenInfoOf(token);
        TokenInfo memory pudInf = s_REGISTRA.tokenInfoOf(s_pud);

        uint price1 = priceOfPoolX96(tokenInf.priceOracle, token);
        uint price2 = priceOfPoolX96(pudInf.priceOracle, s_pud);

        return MathHelper.mulDivRoundUp(price1, amount, price2);
    }

    function valueOfERC721(address token, uint tokenId) external view returns (uint) {
        require(token == address(s_NPM), "only uniswap v3 nft.");
        // TODO try to find value of uniswap v3 nft
    }
}
