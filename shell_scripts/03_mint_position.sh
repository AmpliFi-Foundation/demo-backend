set -o allexport && source env/contracts.env && set +o allexport

forge script script/04_MintPosition.s.sol:MintPosition --rpc-url='http://localhost:8545' --broadcast
