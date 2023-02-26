// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {UD60x18} from "@prb-math/UD60x18.sol";
import "./TokenType.sol";

struct TokenInfo {
    bool enabled;
    TokenType type_;
    address priceOracle;
    UD60x18 liquidationRatio;
}
