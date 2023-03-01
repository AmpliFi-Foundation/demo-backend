set -o allexport && source env/fork-mainnet.env && set +o allexport
forge script script/01_deploy.s.sol:Deploy --rpc-url=$LOCAL_ANVIL --private-key=$ANVIL_PK_0 --broadcast

set -o allexport && source env/contracts.env && set +o allexport
forge script script/02_initRegistra.s.sol:InitRegistra --rpc-url=$LOCAL_ANVIL --private-key=$ANVIL_PK_9 --broadcast