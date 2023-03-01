forge script script/01_Deploy.s.sol:Deploy --rpc-url='http://localhost:8545' --broadcast

set -o allexport && source env/contracts.env && set +o allexport
forge script script/03_InitRegistra.s.sol:InitRegistra --rpc-url='http://localhost:8545' --broadcast