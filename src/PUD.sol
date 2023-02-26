// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {ERC20} from "@openzeppelin-contracts/token/ERC20/ERC20.sol";
import {Registra} from "./Registra.sol";

//TODO: remove abstract once constructor / methods are implemented
abstract contract PUD is ERC20 {
    Registra private immutable s_REGISTRA;
    address private s_bookkeeper;
    address private s_treasurer;

    modifier financiersOnly() {
        require(msg.sender == s_bookkeeper || msg.sender == s_treasurer, "PUD: financiers only");
        _;
    }

    constructor(string memory name, string memory symbol, address registra) ERC20(name, symbol) {
        s_REGISTRA = Registra(registra);
        s_REGISTRA.setPud(address(this));
    }

    function initialize() external {
        s_bookkeeper = s_REGISTRA.getBookkeeper();
        s_treasurer = s_REGISTRA.getTreasurer();
    }

    function mint(uint256 amount) external financiersOnly {
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) external financiersOnly {
        _burn(msg.sender, amount);
    }
}
