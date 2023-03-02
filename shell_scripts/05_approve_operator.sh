set -o allexport && source env/fork-mainnet.env && set +o allexport
set -o allexport && source env/contracts.env && set +o allexport

cast send $AMP_BOOKKEEPER "setApprovalForAll(address, bool)" $AMP_UNISWAP_OPERATOR true --rpc-url=$LOCAL_ANVIL --private-key=$ANVIL_PK_1
