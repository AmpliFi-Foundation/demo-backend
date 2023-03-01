#!/usr/bin/env sh
set -o allexport && source env/fork-mainnet.env && set +o allexport

anvil --fork-url $MAINNET_RPC_URL --fork-block-number $FORK_BLOCK_NUMBER