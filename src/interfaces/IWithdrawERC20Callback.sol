// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

interface IWithdrawERC20Callback {
    function withdrawERC20Callback(
        uint256 positionId,
        address token,
        uint256 amount,
        address recipient,
        bytes calldata data
    ) external;
}
