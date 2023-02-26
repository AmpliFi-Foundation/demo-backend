// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import "./TokenType.sol";

struct TokenInfo {
    bool enabled;
    TokenType type_;
    address priceOracle;
    uint256 liquidationRatioDx18;
}
