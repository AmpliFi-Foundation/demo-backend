// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ERC20 } from "@openzeppelin-contracts/token/ERC20/ERC20.sol";
import { Registra } from "./Registra.sol";

contract PUD is ERC20 {
    Registra private immutable s_REGISTRA;
    address private s_bookkeeper;
    address private s_treasurer;

    modifier requireFinanciers() {
        require(msg.sender == s_bookkeeper || msg.sender == s_treasurer, "PUD: require financiers");
        _;
    }

    modifier testnet_requireSteward() {
        address steward = s_REGISTRA.getSteward();
        require(steward == msg.sender, "only steward allowed");
        _;
    }

    constructor(string memory name, string memory symbol, address registra) ERC20(name, symbol) {
        s_REGISTRA = Registra(registra);
        s_REGISTRA.setPud(address(this));
    }

    // function decimals() public view virtual override returns (uint8) {
    //     return 6;
    // }

    function initialize() external {
        s_bookkeeper = s_REGISTRA.getBookkeeper();
        s_treasurer = s_REGISTRA.getTreasurer();
    }

    function mint(uint amount) external requireFinanciers {
        _mint(msg.sender, amount);
    }

    function testnet_mint(address to, uint amount) external testnet_requireSteward {
        _mint(to, amount);
    }

    function burn(uint amount) external requireFinanciers {
        _burn(msg.sender, amount);
    }
}
