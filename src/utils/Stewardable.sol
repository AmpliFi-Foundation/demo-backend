// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

contract Stewardable {
    address private s_steward;
    address private s_successor;

    modifier requireSteward() {
        require(msg.sender == s_steward, "Require steward");
        _;
    }

    modifier requireSuccessor() {
        require(msg.sender == s_successor, "Require successor");
        _;
    }

    constructor(address steward) {
        s_steward = steward;
    }

    function getSteward() external view returns (address) {
        return s_steward;
    }

    function succeedSteward() external requireSuccessor {
        s_steward = s_successor;
        s_successor = address(0);
    }

    function appointSuccessor(address successor) external requireSteward {
        s_successor = successor;
    }
}
