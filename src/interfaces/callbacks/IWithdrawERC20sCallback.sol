// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

interface IWithdrawERC20sCallback {
    function withdrawERC20sCallback(
        uint positionId,
        address[] calldata tokens,
        uint[] calldata amounts,
        address recipient,
        bytes calldata data
    ) external returns (bytes memory result);
}
