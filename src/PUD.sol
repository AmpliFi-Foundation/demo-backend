// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {ERC20} from "@openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Registra} from "./Registra.sol";

//TODO: remove abstract once constructor / methods are implemented
abstract contract PUD is ERC20 {
    Registra private immutable REGISTRA;
    address private bookkeeper;
    address private treasurer;

    constructor(string memory _name, string memory _symbol, address _registra) ERC20(_name, _symbol) {
        REGISTRA = Registra(_registra);
        REGISTRA.registerPUD(address(this));
    }

    function initialize() external {
        bookkeeper = REGISTRA.bookkeeper();
        treasurer = REGISTRA.treasurer();
    }
}
