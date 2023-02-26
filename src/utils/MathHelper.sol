// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {mulDiv} from "@prb-math/Common.sol";

library MathHelper {
    function mulDivRoundUp(uint256 multiplicand, uint256 multiplier, uint256 denominator)
        internal
        pure
        returns (uint256 result)
    {
        result =
            mulDiv(multiplicand, multiplier, denominator) + mulmod(multiplicand, multiplier, denominator) > 0 ? 1 : 0;
    }
}
