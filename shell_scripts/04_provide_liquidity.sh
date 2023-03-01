set -o allexport && source env/contracts.env && set +o allexport

forge script script/05_ProvideLiquidity.s.sol:ProvideLiquidity --rpc-url='http://localhost:8545' --broadcast
