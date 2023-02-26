// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {Stewardable} from "./libraries/Stewardable.sol";

contract Registra is Stewardable {
    address public bookkeeper;
    address public pud;
    address public treasurer;

    modifier zeroAddressOnly(address _address) {
        require(_address == address(0), "Registra: zero address only");
        _;
    }

    constructor(address _initialSteward) Stewardable(_initialSteward) {}

    function registerBookkeeper(address _bookkeeper) external zeroAddressOnly(bookkeeper) {
        bookkeeper = _bookkeeper;
    }

    function registerPUD(address _pud) external zeroAddressOnly(pud) {
        pud = _pud;
    }

    function registerTreasurer(address _treasurer) external zeroAddressOnly(treasurer) {
        treasurer = _treasurer;
    }
}
