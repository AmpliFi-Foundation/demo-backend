// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

contract Stewardable {
    address private steward;
    address private successor;

    modifier stewardOnly() {
        require(msg.sender == steward, "Steward only");
        _;
    }

    modifier successorOnly() {
        require(msg.sender == successor, "Successor only");
        _;
    }

    constructor(address _steward) {
        steward = _steward;
    }

    function succeedSteward() external successorOnly {
        steward = successor;
        successor = address(0);
    }

    function appointSuccessor(address _successor) external stewardOnly {
        successor = _successor;
    }
}
