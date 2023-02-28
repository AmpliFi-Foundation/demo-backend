// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

interface IWithdrawERC721Callback {
    function withdrawERC721Callback(
        uint256 positionId,
        address token,
        uint256 item,
        address recipient,
        bytes calldata data
    ) external returns (bytes memory result);
}
