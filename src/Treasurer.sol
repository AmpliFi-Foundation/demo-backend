// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { Registra } from "./Registra.sol";
import { TokenInfo } from "./structs/TokenInfo.sol";
import { MathHelper } from "./utils/MathHelper.sol";
import { UniswapV3Math } from "./utils/UniswapV3Math.sol";

import { IUniswapV3Factory } from "src/interfaces/external/uniswap/IUniswapV3Factory.sol";
import { IUniswapV3Pool } from "src/interfaces/external/uniswap/IUniswapV3Pool.sol";
import { INonfungiblePositionManager } from "src/interfaces/external/uniswap/INonfungiblePositionManager.sol";

contract Treasurer {
    Registra private immutable s_REGISTRA;
    INonfungiblePositionManager public immutable s_NPM;
    IUniswapV3Factory public immutable s_FACTORY;

    address private s_bookkeeper;
    address private s_pud;

    constructor(address registra, address npm) {
        s_REGISTRA = Registra(registra);
        s_REGISTRA.setTreasurer(address(this));

        s_NPM = INonfungiblePositionManager(npm);
        s_FACTORY = IUniswapV3Factory(s_NPM.factory());
    }

    function initialize() external {
        s_bookkeeper = s_REGISTRA.getBookkeeper();
        s_pud = s_REGISTRA.getPud();
    }

    function createPUDUniswapV3Pool(address mid, uint160 sqrtPriceX96, uint24 fee) external returns(address pool) {
        pool = s_FACTORY.getPool(s_pud, mid, fee);
        require(pool == address(0), "pool already exists.");

        pool = s_FACTORY.createPool(s_pud, mid, fee);
        IUniswapV3Pool(pool).initialize(sqrtPriceX96);
    }

    function priceOfPoolX96(address pool, address token0) internal view returns (uint) {
        if (pool == address(0)) return UniswapV3Math.Q96;

        IUniswapV3Pool v3Pool = IUniswapV3Pool(pool);

        //TODO calculate time weight price from pool.observe
        (uint160 sqrtPriceX96,,,,,,) = v3Pool.slot0();

        uint priceX96 = MathHelper.mulDivRoundUp(sqrtPriceX96, sqrtPriceX96, UniswapV3Math.Q96);

        if (token0 != v3Pool.token0()) {
            priceX96 = MathHelper.mulDivRoundUp(UniswapV3Math.Q96, UniswapV3Math.Q96, priceX96);
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

    function valueOfERC20s(address[] calldata tokens, uint[] calldata amounts)
        external
        view
        returns (uint[] memory values)
    {
        require(tokens.length == amounts.length, "Treasurer: amounts should aligned with tokens.");

        values = new uint[](tokens.length);

        TokenInfo memory pudInf = s_REGISTRA.tokenInfoOf(s_pud);
        uint price2 = priceOfPoolX96(pudInf.priceOracle, s_pud);

        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i] == s_pud) {
                values[i] = amounts[i];
                continue;
            }

            TokenInfo memory tokenInfo = s_REGISTRA.tokenInfoOf(tokens[i]);

            if (amounts[i] == 0) {
                continue;
            }

            uint price1 = priceOfPoolX96(tokenInfo.priceOracle, tokens[i]);
            values[i] = MathHelper.mulDivRoundUp(price1, amounts[i], price2);
        }
    }

    struct UniswapV3Position {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    function amountsOfUniswapV3NFT(UniswapV3Position memory pos)
        internal
        view
        virtual
        returns (uint amount0, uint amount1)
    {
        amount0 += uint(pos.tokensOwed0);
        amount1 += uint(pos.tokensOwed1);

        if (pos.liquidity == 0) {
            return (amount0, amount1);
        }

        address pool = s_FACTORY.getPool(pos.token0, pos.token1, pos.fee);
        require(pool != address(0), "Treasurer: uniswap v3 pool not found.");

        (uint160 sqrtPriceBx96Curr,,,,,,) = IUniswapV3Pool(pool).slot0();
        uint160 sqrtPriceBx96Lower = UniswapV3Math.getSqrtRatioAtTick(pos.tickLower);
        uint160 sqrtPriceBx96Upper = UniswapV3Math.getSqrtRatioAtTick(pos.tickUpper);

        if (sqrtPriceBx96Curr >= sqrtPriceBx96Upper) {
            // all asset converted to token1
            amount1 += UniswapV3Math.getAmount1Delta(sqrtPriceBx96Upper, sqrtPriceBx96Lower, pos.liquidity);
        } else if (sqrtPriceBx96Curr <= sqrtPriceBx96Lower) {
            // all asset converted to token0
            amount0 += UniswapV3Math.getAmount0Delta(sqrtPriceBx96Lower, sqrtPriceBx96Upper, pos.liquidity);
        } else {
            amount1 += UniswapV3Math.getAmount1Delta(sqrtPriceBx96Curr, sqrtPriceBx96Lower, pos.liquidity);
            amount0 += UniswapV3Math.getAmount0Delta(sqrtPriceBx96Curr, sqrtPriceBx96Upper, pos.liquidity);
        }
    }

    function valueOfUniswapV3NFT(uint tokenId)
        internal
        view
        returns (address token0, address token1, uint value0, uint value1)
    {
        UniswapV3Position memory pos;
        (
            ,
            ,
            pos.token0,
            pos.token1,
            pos.fee,
            pos.tickLower,
            pos.tickUpper,
            pos.liquidity,
            ,
            ,
            pos.tokensOwed0,
            pos.tokensOwed1
        ) = s_NPM.positions(tokenId);

        address[] memory tokens = new address[](2);
        uint[] memory amounts = new uint[](2);

        tokens[0] = pos.token0;
        tokens[1] = pos.token1;

        (amounts[0], amounts[1]) = amountsOfUniswapV3NFT(pos);
        uint[] memory values = this.valueOfERC20s(tokens, amounts);

        (token0, token1) = (pos.token0, pos.token1);
        (value0, value1) = (values[0], values[1]);
    }

    function valueOfERC721s(address[] calldata tokens, uint[] calldata items)
        external
        view
        returns (address[] memory tokens_, uint[] memory values)
    {
        uint resultNums;
        for (uint i = 0; i < tokens.length; i++) {
            // TODO Support more ERC721 than Uniswap V3 NFT
            require(tokens[i] == address(s_NPM), "only uniswap v3 nft.");
            resultNums += 2;
        }

        tokens_ = new address[](resultNums);
        values = new uint[](resultNums);

        uint idx = 0;
        for (uint i = 0; i < tokens.length; i++) {
            (tokens_[idx], tokens_[idx + 1], values[idx], values[idx + 1]) = valueOfUniswapV3NFT(items[i]);
            idx += 2;
        }
    }
}
