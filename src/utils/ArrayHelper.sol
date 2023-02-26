// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

library ArrayHelper {
    function remove(address[] storage s_self, address item) internal {
        uint256 length = s_self.length; //gas saving
        for (uint256 i = 0; i < length; i++) {
            if (s_self[i] == item) {
                if (i != length - 1) {
                    s_self[i] = s_self[length - 1]; //gas saving
                }
                s_self.pop();
                break;
            }
        }
    }

    function remove(uint256[] storage s_self, uint256 item) internal {
        uint256 length = s_self.length; //gas saving
        for (uint256 i = 0; i < length; i++) {
            if (s_self[i] == item) {
                if (i != length - 1) {
                    s_self[i] = s_self[length - 1]; //gas saving
                }
                s_self.pop();
                break;
            }
        }
    }
}
