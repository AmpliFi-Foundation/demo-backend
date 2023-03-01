// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { IERC20, SafeERC20 } from "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC721, ERC721 } from "@openzeppelin-contracts/token/ERC721/ERC721.sol";
import { Address } from "@openzeppelin-contracts/utils/Address.sol";
import { Math } from "@openzeppelin-contracts/utils/math/Math.sol";
import { UD60x18, UNIT, unwrap, mul, mulDiv18, powu } from "@prb-math/UD60x18.sol";
import { IBorrowCallback } from "./interfaces/callbacks/IBorrowCallback.sol";
import { IWithdrawERC20Callback } from "./interfaces/callbacks/IWithdrawERC20Callback.sol";
import { IWithdrawERC20sCallback } from "./interfaces/callbacks/IWithdrawERC20sCallback.sol";
import { IWithdrawERC721Callback } from "./interfaces/callbacks/IWithdrawERC721Callback.sol";
import { TokenInfo, TokenType } from "./structs/TokenInfo.sol";
import { Position, PositionHelper } from "./utils/PositionHelper.sol";
import { PUD } from "./PUD.sol";
import { Treasurer } from "./Treasurer.sol";
import { Registra } from "./Registra.sol";

contract Bookkeeper is ERC721 {
    using SafeERC20 for IERC20;
    using PositionHelper for Position;

    Registra private immutable s_REGISTRA;
    address private s_pud;
    address private s_treasurer;
    uint private s_lastBlockTimestamp;
    UD60x18 private s_interestCumulative;

    uint private s_totalRealDebt;
    uint private s_lastPositionId;
    mapping(uint => Position) private s_positions;
    mapping(address => uint) private s_erc20TotalBalances;
    mapping(address => mapping(uint => uint)) private s_erc721Positions;

    event DepositERC20(address indexed operator, uint indexed positionId, address token, uint amount);
    event DepositERC721(address indexed operator, uint indexed positionId, address token, uint item);
    event WithdrawalERC20(
        address indexed operator, uint indexed positionId, address token, uint amount, address recipient
    );
    event WithdrawalERC20s(
        address indexed operator, uint indexed positionId, address[] tokens, uint[] amounts, address recipient
    );
    event WithdrawalERC721(
        address indexed operator, uint indexed positionId, address token, uint item, address recipient
    );
    event Borrowing(address indexed operator, uint indexed positionId, uint amount);
    event Repayment(address indexed operator, uint indexed positionId, uint principal, uint interest);

    modifier requireOwnerOrOperator(address owner) {
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Bookkeeper: require owner or operator");
        _;
    }

    modifier requirePosition(uint positionId) {
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
        s_lastBlockTimestamp = block.timestamp;
        s_interestCumulative = UNIT;
    }

    function mint(address recipient) external requireOwnerOrOperator(recipient) returns (uint positionId) {
        positionId = ++s_lastPositionId;
        _safeMint(recipient, positionId);
    }

    function depositERC20(uint positionId, address token, uint amount)
        external
        requirePosition(positionId)
        requireToken(token, TokenType.ERC20)
    {
        depositERC20Core(s_positions[positionId], token, amount);

        emit DepositERC20(msg.sender, positionId, token, amount);
    }

    function depositERC721(uint positionId, address token, uint item)
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
    function withdrawERC20(uint positionId, address token, uint amount, address recipient, bytes calldata data)
        external
        requirePosition(positionId)
        requireOwnerOrOperator(ownerOf(positionId))
        requireNonzeroAddress(recipient)
        returns (bytes memory callbackResult)
    {
        Position storage s_position = s_positions[positionId];

        withdrawERC20Core(s_position, token, amount);
        IERC20(token).safeTransfer(recipient, amount);
        if (Address.isContract(msg.sender)) {
            callbackResult =
                IWithdrawERC20Callback(msg.sender).withdrawERC20Callback(positionId, token, amount, recipient, data);
        }

        emit WithdrawalERC20(msg.sender, positionId, token, amount, recipient);
    }

    //TODO: need to ensure equity ratio >= liquidation ratio
    function withdrawERC20s(
        uint positionId,
        address[] calldata tokens,
        uint[] calldata amounts,
        address recipient,
        bytes calldata data
    )
        external
        requirePosition(positionId)
        requireOwnerOrOperator(ownerOf(positionId))
        requireNonzeroAddress(recipient)
        returns (bytes memory callbackResult)
    {
        Position storage s_position = s_positions[positionId];
        require(tokens.length == amounts.length, "Bookkeeper: tokens and amounts are different in length");

        for (uint i = tokens.length - 1; i >= 0; i--) {
            withdrawERC20Core(s_position, tokens[i], amounts[i]);
            IERC20(tokens[i]).safeTransfer(recipient, amounts[i]);
        }
        if (Address.isContract(msg.sender)) {
            callbackResult =
                IWithdrawERC20sCallback(msg.sender).withdrawERC20sCallback(positionId, tokens, amounts, recipient, data);
        }

        emit WithdrawalERC20s(msg.sender, positionId, tokens, amounts, recipient);
    }

    //TODO: need to ensure equity ratio >= liquidation ratio
    function withdrawERC721(uint positionId, address token, uint item, address recipient, bytes calldata data)
        external
        requirePosition(positionId)
        requireOwnerOrOperator(ownerOf(positionId))
        requireNonzeroAddress(recipient)
        returns (bytes memory callbackResult)
    {
        require(IERC721(token).ownerOf(item) == address(this), "Bookkeeper: token not present");
        require(s_erc721Positions[token][item] == positionId, "Bookkeeper: token not in the position");

        s_positions[positionId].removeERC721(token, item);
        delete s_erc721Positions[token][item];
        IERC721(token).safeTransferFrom(address(this), recipient, item);
        if (Address.isContract(msg.sender)) {
            callbackResult =
                IWithdrawERC721Callback(msg.sender).withdrawERC721Callback(positionId, token, item, recipient, data);
        }

        emit WithdrawalERC721(msg.sender, positionId, token, item, recipient);
    }

    //TODO: need to ensure equity ratio >= liquidation ratio
    function borrow(uint positionId, uint amount, bytes calldata data)
        external
        requirePosition(positionId)
        requireOwnerOrOperator(ownerOf(positionId))
    {
        address pud = s_pud; //gas saving
        Position storage s_position = s_positions[positionId];

        s_totalRealDebt += s_position.addDebt(amount, getInterestCumulative());
        PUD(pud).mint(amount);
        depositERC20Core(s_position, pud, amount);
        if (Address.isContract(msg.sender)) {
            IBorrowCallback(msg.sender).borrowCallback(positionId, amount, data);
        }

        emit Borrowing(msg.sender, positionId, amount);
    }

    function repay(uint positionId, uint amount)
        external
        requirePosition(positionId)
        requireOwnerOrOperator(ownerOf(positionId))
    {
        address pud = s_pud; //gas saving
        Position storage s_position = s_positions[positionId];
        amount = Math.min(amount, debtOfCore(s_position));
        require(s_position.erc20Balances[pud] >= amount, "Bookkeeper: insufficient PUD balance");

        uint principal = Math.min(amount, s_position.nominalDebt);
        uint interest = Math.max(amount, principal) - principal;
        withdrawERC20Core(s_position, pud, amount);
        PUD(pud).burn(principal);
        if (interest > 0) {
            IERC20(pud).safeTransfer(s_treasurer, interest);
        }
        s_totalRealDebt -= s_position.removeDebt(amount, getInterestCumulative());

        emit Repayment(msg.sender, positionId, principal, interest);
    }

    function burn(uint positionId) external requirePosition(positionId) requireOwnerOrOperator(ownerOf(positionId)) {
        Position storage s_position = s_positions[positionId];
        require(s_position.erc20Tokens.length == 0 && s_position.erc721Tokens.length == 0, "Bookkeeper: not asset free");
        require(s_position.realDebt == 0 && s_position.nominalDebt == 0, "Bookkeeper: not debt free");

        delete s_positions[positionId];
        _burn(positionId);
    }

    function debtOf(uint positionId) external returns (uint debt) {
        debt = debtOfCore(s_positions[positionId]);
    }

    function getERC20Stats(uint positionId)
        external
        view
        requirePosition(positionId)
        returns (address[] memory tokens, uint[] memory amounts, uint[] memory values, uint[] memory minEquities)
    {
        (tokens, amounts) = s_positions[positionId].getERC20s();
        values = Treasurer(s_treasurer).valueOfERC20s(tokens, amounts);
        minEquities = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            minEquities[i] = mulDiv18(values[i], unwrap(s_REGISTRA.tokenInfoOf(tokens[i]).liquidationRatio));
        }
    }

    function onERC721Received(address, address, uint, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function depositERC20Core(Position storage s_position, address token, uint amount) private {
        uint newBalance = s_erc20TotalBalances[token] + amount; //gas saving
        require(IERC20(token).balanceOf(address(this)) >= newBalance, "Bookkeeper: insufficient ERC-20 deposit");

        s_position.addERC20(token, amount);
        s_erc20TotalBalances[token] = newBalance;
    }

    function withdrawERC20Core(Position storage s_position, address token, uint amount) private {
        require(s_position.erc20Balances[token] >= amount, "Bookkeeper: insufficient token balance");

        s_position.removeERC20(token, amount);
        s_erc20TotalBalances[token] -= amount;
    }

    function debtOfCore(Position storage s_position) private returns (uint debt) {
        debt = mulDiv18(s_position.realDebt, unwrap(getInterestCumulative()));
    }

    function getInterestCumulative() private returns (UD60x18 interestCumulative) {
        uint timeElapsed = block.timestamp - s_lastBlockTimestamp;

        if (timeElapsed > 0) {
            s_interestCumulative = mul(s_interestCumulative, powu(s_REGISTRA.getInterestRate(), timeElapsed));
            s_lastBlockTimestamp = block.timestamp;
        }
        interestCumulative = s_interestCumulative;
    }
}
