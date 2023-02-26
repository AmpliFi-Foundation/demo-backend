// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {ERC721} from "@openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Position} from "./structs/Position.sol";
import {Registra} from "./Registra.sol";

contract Bookkeeper is ERC721 {
    Registra private immutable REGISTRA;
    address private pud;
    address private treasurer;
    mapping(uint256 => Position) private positions;

    constructor(string memory _name, string memory _symbol, address _registra) ERC721(_name, _symbol) {
        REGISTRA = Registra(_registra);
        REGISTRA.registerBookkeeper(address(this));
    }

    function initialize() external {
        pud = REGISTRA.pud();
        treasurer = REGISTRA.treasurer();
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
