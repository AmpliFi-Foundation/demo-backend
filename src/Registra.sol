// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {UD60x18} from "@prb-math/UD60x18.sol";
import {TokenInfo} from "./structs/TokenInfo.sol";
import {Stewardable} from "./utils/Stewardable.sol";

contract Registra is Stewardable {
    address private s_bookkeeper;
    address private s_pud;
    address private s_treasurer;
    UD60x18 private s_interestRate;
    UD60x18 private s_penaltyRate;
    mapping(address => TokenInfo) private s_tokenInfos;

    modifier zeroAddressOnly(address address_) {
        require(address_ == address(0), "Registra: zero address only");
        _;
    }

    constructor(address steward) Stewardable(steward) {}

    function setBookkeeper(address bookkeeper) external zeroAddressOnly(s_bookkeeper) {
        s_bookkeeper = bookkeeper;
    }

    function setPud(address pud) external zeroAddressOnly(s_pud) {
        s_pud = pud;
    }

    function setTreasurer(address treasurer) external zeroAddressOnly(s_treasurer) {
        s_treasurer = treasurer;
    }

    function setInterestRate(UD60x18 interestRate) external stewardOnly {
        s_interestRate = interestRate;
    }

    function setPenaltyRate(UD60x18 penaltyRate) external stewardOnly {
        s_penaltyRate = penaltyRate;
    }

    function setTokenInfo(address token, TokenInfo calldata tokenInfo) external stewardOnly {
        s_tokenInfos[token] = tokenInfo;
    }

    function getBookkeeper() external view returns (address bookkeeper) {
        bookkeeper = s_bookkeeper;
    }

    function getPud() external view returns (address pud) {
        pud = s_pud;
    }

    function getTreasurer() external view returns (address treasurer) {
        treasurer = s_treasurer;
    }

    function getInterestRate() external view returns (UD60x18 interestRate) {
        interestRate = s_interestRate;
    }

    function getPenaltyRate() external view returns (UD60x18 penaltyRate) {
        penaltyRate = s_penaltyRate;
    }

    function tokenInfoOf(address token) external view returns (TokenInfo memory tokenInfo) {
        tokenInfo = s_tokenInfos[token];
    }
}
