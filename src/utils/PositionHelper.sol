// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { UD60x18, uUNIT, unwrap } from "@prb-math/UD60x18.sol";
import "../structs/Position.sol";
import "./ArrayHelper.sol";
import "./MathHelper.sol";

library PositionHelper {
    using ArrayHelper for address[];
    using ArrayHelper for uint[];

    function addERC20(Position storage s_self, address token, uint amount) internal {
        uint oldBalance = s_self.erc20Balances[token]; //gas saving

        if (oldBalance == 0) {
            s_self.erc20Tokens.push(token);
        }
        s_self.erc20Balances[token] = oldBalance + amount;
    }

    function addERC721(Position storage s_self, address token, uint item) internal {
        if (s_self.erc721Items[token].length == 0) {
            s_self.erc721Tokens.push(token);
        }
        s_self.erc721Items[token].push(item);
    }

    function addDebt(Position storage s_self, uint nominalAmount, UD60x18 interestCumulative)
        internal
        returns (uint realAmount)
    {
        realAmount = MathHelper.mulDivRoundUp(nominalAmount, uUNIT, unwrap(interestCumulative));
        s_self.realDebt += realAmount;
        s_self.nominalDebt += nominalAmount;
    }

    function removeERC20(Position storage s_self, address token, uint amount) internal {
        uint newBalance = s_self.erc20Balances[token] - amount; //gas saving

        s_self.erc20Balances[token] = newBalance;
        if (newBalance == 0) {
            s_self.erc20Tokens.remove(token);
        }
    }

    function removeERC721(Position storage s_self, address token, uint item) internal {
        s_self.erc721Items[token].remove(item);
        if (s_self.erc721Items[token].length == 0) {
            s_self.erc721Tokens.remove(token);
        }
    }

    function removeDebt(Position storage s_self, uint nominalAmount, UD60x18 interestCumulative)
        internal
        returns (uint realAmount)
    {
        uint nominalDebt = s_self.nominalDebt; //gas saving

        realAmount = mulDiv(nominalAmount, uUNIT, unwrap(interestCumulative));
        s_self.realDebt -= realAmount;
        s_self.nominalDebt = nominalAmount >= nominalDebt ? 0 : nominalDebt - nominalAmount;
    }

    function getERC20s(Position storage s_self)
        internal
        view
        returns (address[] memory tokens, uint[] memory amounts)
    {
        tokens = s_self.erc20Tokens;
        amounts = new uint[] (tokens.length);

        for (uint i = 0; i < tokens.length; i++) {
            amounts[i] = s_self.erc20Balances[tokens[i]];
        }
    }

    function getERC721s(Position storage s_self) internal view returns (address[] memory tokens, uint[] memory items) {
        address[] memory tokens_ = s_self.erc721Tokens; //gas saving
        uint size;
        for (uint i = 0; i < tokens_.length; i++) {
            size += s_self.erc721Items[tokens_[i]].length;
        }

        tokens = new address[](size);
        items = new uint[](size);

        for (uint i = 0; i < tokens_.length; i++) {
            uint[] memory items_ = s_self.erc721Items[tokens_[i]];
            for (uint j = 0; j < items_.length; j++) {
                tokens[--size] = tokens_[i];
                items[size] = items_[j];
            }
        }
    }
}
