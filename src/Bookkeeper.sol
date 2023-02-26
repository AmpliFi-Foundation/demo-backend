// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {ERC721} from "@openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Position} from "./structs/Position.sol";
import {Registra} from "./Registra.sol";

contract Bookkeeper is ERC721 {
    Registra private immutable REGISTRA;
    address private pud;
    address private treasurer;

    uint256 private lastPositionId;
    mapping(uint256 => Position) private positions;

    modifier ownerOrOperatorOnly(address _owner) {
        require(msg.sender == _owner || isApprovedForAll(_owner, msg.sender), "Bookkeeper: owner or operator only");
        _;
    }

    modifier existingPositionOnly(uint256 _positionId) {
        require(_exists(_positionId), "Bookkeeper: require existing _position");
        _;
    }

    constructor(string memory _name, string memory _symbol, address _registra) ERC721(_name, _symbol) {
        REGISTRA = Registra(_registra);
        REGISTRA.registerBookkeeper(address(this));
    }

    function initialize() external {
        pud = REGISTRA.pud();
        treasurer = REGISTRA.treasurer();
    }

    function mint(address _recipient) external ownerOrOperatorOnly(_recipient) returns (uint256 _positionId) {
        _positionId = ++lastPositionId;
        _safeMint(_recipient, _positionId);
    }

    function burn(uint256 _positionId)
        external
        existingPositionOnly(_positionId)
        ownerOrOperatorOnly(ownerOf(_positionId))
    {
        Position storage _position = positions[_positionId];
        require(_position.erc20Tokens.length == 0 && _position.erc721Tokens.length == 0, "Bookkeeper: not asset free");
        require(_position.realDebt == 0 && _position.nominalDebt == 0, "Bookkeeper: not debt free");

        delete positions[_positionId];
        _burn(_positionId);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
