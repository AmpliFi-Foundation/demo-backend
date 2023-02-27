// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {UD60x18, uUNIT, unwrap} from "@prb-math/UD60x18.sol";
import "../structs/Position.sol";
import "./ArrayHelper.sol";
import "./MathHelper.sol";

library PositionHelper {
    using ArrayHelper for address[];
    using ArrayHelper for uint256[];

    function addERC20(Position storage s_self, address token, uint256 amount) internal {
        uint256 oldBalance = s_self.erc20Balances[token]; //gas saving

        if (oldBalance == 0) {
            s_self.erc20Tokens.push(token);
        }
        s_self.erc20Balances[token] = oldBalance + amount;
    }

    function addERC721(Position storage s_self, address token, uint256 item) internal {
        if (s_self.erc721Items[token].length == 0) {
            s_self.erc721Tokens.push(token);
        }
        s_self.erc721Items[token].push(item);
    }

    function addDebt(Position storage s_self, uint256 nominalAmount, UD60x18 interestCumulative)
        internal
        returns (uint256 realAmount)
    {
        realAmount = MathHelper.mulDivRoundUp(nominalAmount, uUNIT, unwrap(interestCumulative));
        s_self.realDebt += realAmount;
        s_self.nominalDebt += nominalAmount;
    }

    function removeERC20(Position storage s_self, address token, uint256 amount) internal {
        uint256 newBalance = s_self.erc20Balances[token] - amount; //gas saving

        s_self.erc20Balances[token] = newBalance;
        if (newBalance == 0) {
            s_self.erc20Tokens.remove(token);
        }
    }

    function removeERC721(Position storage s_self, address token, uint256 item) internal {
        s_self.erc721Items[token].remove(item);
        if (s_self.erc721Items[token].length == 0) {
            s_self.erc721Tokens.remove(token);
        }
    }

    function removeDebt(Position storage s_self, uint256 nominalAmount, UD60x18 interestCumulative)
        internal
        returns (uint256 realAmount)
    {
        uint256 nominalDebt = s_self.nominalDebt; //gas saving

        realAmount = mulDiv(nominalAmount, uUNIT, unwrap(interestCumulative));
        s_self.realDebt -= realAmount;
        s_self.nominalDebt = nominalAmount >= nominalDebt ? 0 : nominalDebt - nominalAmount;
    }
}
