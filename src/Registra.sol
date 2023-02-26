// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {TokenInfo} from "./structs/TokenInfo.sol";
import {Stewardable} from "./utils/Stewardable.sol";

contract Registra is Stewardable {
    address public bookkeeper;
    address public pud;
    address public treasurer;
    uint256 public interestRateDx18;
    uint256 public penaltyRateDx18;

    mapping(address => TokenInfo) private tokenInfos;

    modifier zeroAddressOnly(address _address) {
        require(_address == address(0), "Registra: zero address only");
        _;
    }

    constructor(address _initialSteward) Stewardable(_initialSteward) {}

    function registerBookkeeper(address _bookkeeper) external zeroAddressOnly(bookkeeper) {
        bookkeeper = _bookkeeper;
    }

    function registerPUD(address _pud) external zeroAddressOnly(pud) {
        pud = _pud;
    }

    function registerTreasurer(address _treasurer) external zeroAddressOnly(treasurer) {
        treasurer = _treasurer;
    }

    function setInterestRateDx18(uint256 _interestRateDx18) external stewardOnly {
        interestRateDx18 = _interestRateDx18;
    }

    function setPenaltyRateDx18(uint256 _penaltyRateDx18) external stewardOnly {
        penaltyRateDx18 = _penaltyRateDx18;
    }

    function setTokenInfo(address _token, TokenInfo calldata _tokenInfo) external stewardOnly {
        tokenInfos[_token] = _tokenInfo;
    }

    function tokenInfoOf(address _token) external view returns (TokenInfo memory _tokenInfo) {
        _tokenInfo = tokenInfos[_token];
    }
}
