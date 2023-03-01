set -o allexport && source env/fork-mainnet.env && set +o allexport
set -o allexport && source env/contracts.env && set +o allexport

cast rpc evm_setAutomine true

# transfer some USDC to anvil address 1, 2
cast rpc anvil_impersonateAccount 0x28C6c06298d514Db089934071355E5743bf21d60 --rpc-url=$LOCAL_ANVIL
cast send $USDC --from 0x28C6c06298d514Db089934071355E5743bf21d60 "transfer(address,uint256)(bool)" $ANVIL_ADDR_1 1000000000000 --rpc-url=$LOCAL_ANVIL
cast send $USDC --from 0x28C6c06298d514Db089934071355E5743bf21d60 "transfer(address,uint256)(bool)" $ANVIL_ADDR_2 1000000000000 --rpc-url=$LOCAL_ANVIL

# transfer some DAI to anvil address
cast rpc anvil_impersonateAccount 0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8 --rpc-url=$LOCAL_ANVIL
cast send $DAI --from 0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8 "transfer(address,uint256)(bool)" $ANVIL_ADDR_1 '1000000 ether' --rpc-url=$LOCAL_ANVIL
cast send $DAI --from 0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8 "transfer(address,uint256)(bool)" $ANVIL_ADDR_2 '1000000 ether' --rpc-url=$LOCAL_ANVIL