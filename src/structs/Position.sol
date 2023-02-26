// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

struct Position {
    uint256 realDebt;
    uint256 nominalDebt;
    address[] erc20Tokens;
    mapping(address => uint256) erc20Balances;
    address[] erc721Tokens;
    mapping(address => uint256[]) erc721Items;
}
