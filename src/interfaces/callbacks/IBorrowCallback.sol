// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

interface IBorrowCallback {
    function borrowCallback(uint256 positionId, uint256 amount, bytes calldata data) external;
}
