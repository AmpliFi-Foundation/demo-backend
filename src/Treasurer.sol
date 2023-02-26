// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {Registra} from "./Registra.sol";

contract Treasurer {
    Registra private immutable s_REGISTRA;
    address private s_bookkeeper;
    address private s_pud;

    constructor(address registra) {
        s_REGISTRA = Registra(registra);
        s_REGISTRA.setTreasurer(address(this));
    }

    function initialize() external {
        s_bookkeeper = s_REGISTRA.getBookkeeper();
        s_pud = s_REGISTRA.getPud();
    }
}
