// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {Registra} from "./Registra.sol";

contract Treasurer {
    Registra private immutable REGISTRA;
    address private bookkeeper;
    address private pud;

    constructor(address _registra) {
        REGISTRA = Registra(_registra);
        REGISTRA.registerBookkeeper(address(this));
    }

    function initialize() external {
        bookkeeper = REGISTRA.bookkeeper();
        pud = REGISTRA.pud();
    }
}
