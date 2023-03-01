set -o allexport && source env/fork-mainnet.env && set +o allexport
set -o allexport && source env/contracts.env && set +o allexport

cast send $AMP_BOOKKEEPER "mint(address)(uint)" $ANVIL_ADDR_1 --rpc-url=$LOCAL_ANVIL --private-key=$ANVIL_PK_1
cast send $USDC "transfer(address,uint)" $AMP_BOOKKEEPER 1000000000 --rpc-url=$LOCAL_ANVIL --private-key=$ANVIL_PK_1
cast send $AMP_BOOKKEEPER "depositERC20(uint,address,uint)" 1 $USDC 1000000000 --rpc-url=$LOCAL_ANVIL --private-key=$ANVIL_PK_1