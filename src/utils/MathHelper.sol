// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { mulDiv } from "@prb-math/Common.sol";

library MathHelper {
    function mulDivRoundUp(uint multiplicand, uint multiplier, uint denominator) internal pure returns (uint result) {
        result =
            mulDiv(multiplicand, multiplier, denominator) + mulmod(multiplicand, multiplier, denominator) > 0 ? 1 : 0;
    }

    function divRoundUp(uint numerator, uint denominator) internal pure returns (uint result) {
        assembly {
            result := add(div(numerator, denominator), gt(mod(numerator, denominator), 0))
        }
    }
}
