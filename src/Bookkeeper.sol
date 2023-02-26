// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {ERC721} from "@openzeppelin-contracts/token/ERC721/ERC721.sol";
import {Position} from "./structs/Position.sol";
import {Registra} from "./Registra.sol";

contract Bookkeeper is ERC721 {
    Registra private immutable s_REGISTRA;
    address private s_pud;
    address private s_treasurer;
    uint256 private s_lastPositionId;
    mapping(uint256 => Position) private s_positions;

    modifier requireOwnerOrOperator(address owner) {
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Bookkeeper: require owner or operator");
        _;
    }

    modifier requirePosition(uint256 positionId) {
        require(_exists(positionId), "Bookkeeper: require position");
        _;
    }

    constructor(string memory name, string memory symbol, address registra) ERC721(name, symbol) {
        s_REGISTRA = Registra(registra);
        s_REGISTRA.setBookkeeper(address(this));
    }

    function initialize() external {
        s_pud = s_REGISTRA.getPud();
        s_treasurer = s_REGISTRA.getTreasurer();
    }

    function mint(address recipient) external requireOwnerOrOperator(recipient) returns (uint256 positionId) {
        positionId = ++s_lastPositionId;
        _safeMint(recipient, positionId);
    }

    function burn(uint256 positionId)
        external
        requirePosition(positionId)
        requireOwnerOrOperator(ownerOf(positionId))
    {
        Position storage s_position = s_positions[positionId];
        require(s_position.erc20Tokens.length == 0 && s_position.erc721Tokens.length == 0, "Bookkeeper: not asset free");
        require(s_position.realDebt == 0 && s_position.nominalDebt == 0, "Bookkeeper: not debt free");

        delete s_positions[positionId];
        _burn(positionId);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
