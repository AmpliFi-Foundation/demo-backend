// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {IERC20, SafeERC20} from "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC721, ERC721} from "@openzeppelin-contracts/token/ERC721/ERC721.sol";
import {Address} from "@openzeppelin-contracts/utils/Address.sol";
import {IWithdrawERC20Callback} from "./interfaces/IWithdrawERC20Callback.sol";
import {IWithdrawERC721Callback} from "./interfaces/IWithdrawERC721Callback.sol";
import {TokenInfo, TokenType} from "./structs/TokenInfo.sol";
import {Position, PositionHelper} from "./utils/PositionHelper.sol";
import {Registra} from "./Registra.sol";

contract Bookkeeper is ERC721 {
    using SafeERC20 for IERC20;
    using PositionHelper for Position;

    Registra private immutable s_REGISTRA;
    address private s_pud;
    address private s_treasurer;
    uint256 private s_lastPositionId;
    mapping(uint256 => Position) private s_positions;
    mapping(address => uint256) private s_erc20TotalBalances;
    mapping(address => mapping(uint256 => uint256)) private s_erc721Positions;

    event DepositERC20(address indexed operator, uint256 indexed positionId, address token, uint256 amount);
    event DepositERC721(address indexed operator, uint256 indexed positionId, address token, uint256 item);
    event WithdrawalERC20(
        address indexed operator, uint256 indexed positionId, address token, uint256 amount, address recipient
    );
    event WithdrawalERC721(
        address indexed operator, uint256 indexed positionId, address token, uint256 item, address recipient
    );

    modifier requireOwnerOrOperator(address owner) {
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Bookkeeper: require owner or operator");
        _;
    }

    modifier requirePosition(uint256 positionId) {
        require(_exists(positionId), "Bookkeeper: require position");
        _;
    }

    modifier requireToken(address token, TokenType tokenType) {
        TokenInfo memory tokenInfo = s_REGISTRA.tokenInfoOf(token);
        require(tokenInfo.enabled, "Bookkeeper: require enabled token");
        require(tokenInfo.type_ == tokenType, "Bookkeeper: require right token type");
        _;
    }

    modifier requireNonzeroAddress(address address_) {
        require(address_ != address(0), "Bookkeeper: require non-zero address");
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

    function depositERC20(uint256 positionId, address token, uint256 amount)
        external
        requirePosition(positionId)
        requireToken(token, TokenType.ERC20)
    {
        uint256 newBalance = s_erc20TotalBalances[token] + amount; //gas saving
        require(IERC20(token).balanceOf(address(this)) >= newBalance, "Bookkeeper: insufficient ERC-20 deposit");

        s_positions[positionId].addERC20(token, amount);
        s_erc20TotalBalances[token] = newBalance;

        emit DepositERC20(msg.sender, positionId, token, amount);
    }

    function depositERC721(uint256 positionId, address token, uint256 item)
        external
        requirePosition(positionId)
        requireToken(token, TokenType.ERC721)
    {
        require(IERC721(token).ownerOf(item) == address(this), "Bookkeeper: missing ERC-721 deposit");
        require(s_erc721Positions[token][item] == 0, "Bookkeeper: ERC-721 already deposited");

        s_positions[positionId].addERC721(token, item);
        s_erc721Positions[token][item] = positionId;

        emit DepositERC721(msg.sender, positionId, token, item);
    }

    //TODO: need to ensure equity ratio >= liquidation ratio
    function withdrawERC20(uint256 positionId, address token, uint256 amount, address recipient, bytes calldata data)
        external
        requirePosition(positionId)
        requireOwnerOrOperator(ownerOf(positionId))
        requireNonzeroAddress(recipient)
    {
        Position storage s_position = s_positions[positionId]; //gas saving
        require(s_position.erc20Balances[token] >= amount, "Bookkeeper: insufficient ERC-20 balance");

        s_position.removeERC20(token, amount);
        s_erc20TotalBalances[token] -= amount;
        IERC20(token).safeTransfer(recipient, amount);
        if (Address.isContract(msg.sender)) {
            IWithdrawERC20Callback(msg.sender).withdrawERC20Callback(positionId, token, amount, recipient, data);
        }

        emit WithdrawalERC20(msg.sender, positionId, token, amount, recipient);
    }

    //TODO: need to ensure equity ratio >= liquidation ratio
    function withdrawERC721(uint256 positionId, address token, uint256 item, address recipient, bytes calldata data)
        external
        requirePosition(positionId)
        requireOwnerOrOperator(ownerOf(positionId))
        requireNonzeroAddress(recipient)
    {
        require(IERC721(token).ownerOf(item) == address(this), "Bookkeeper: token not present");
        require(s_erc721Positions[token][item] == positionId, "Bookkeeper: token not in the position");

        s_positions[positionId].removeERC721(token, item);
        delete s_erc721Positions[token][item];
        IERC721(token).safeTransferFrom(address(this), recipient, item);
        if (Address.isContract(msg.sender)) {
            IWithdrawERC721Callback(msg.sender).withdrawERC721Callback(positionId, token, item, recipient, data);
        }

        emit WithdrawalERC721(msg.sender, positionId, token, item, recipient);
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
