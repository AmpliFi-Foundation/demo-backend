// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

contract Stewardable {
    address private s_steward;
    address private s_successor;

    modifier stewardOnly() {
        require(msg.sender == s_steward, "Steward only");
        _;
    }

    modifier successorOnly() {
        require(msg.sender == s_successor, "Successor only");
        _;
    }

    constructor(address steward) {
        s_steward = steward;
    }

    function succeedSteward() external successorOnly {
        s_steward = s_successor;
        s_successor = address(0);
    }

    function appointSuccessor(address successor) external stewardOnly {
        s_successor = successor;
    }
}
