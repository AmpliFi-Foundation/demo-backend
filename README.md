# Amplifi demo backend

## Goerli testnet

Depolyment information can be found in goerli branch.

## Local development

Required dependency
    - foundry
    - solidity 0.8.19

After install dependency, run following command to install all library:

```shell
demo-backend > forge install
```

## Run local fork-mainnet anvil node

An `INFURA_KEY` is needed to fork the mainnet, following command start a local anvil node.

```shell
> export INFURA_KEY=<infura_mainnet_api_secrets>
> chmod +x shell_scripts/00_run_anvil.sh
> ./shell_scripts/00_run_anvil.sh
```

## Deploy contract to local development evm

```shell
> chmod +x shell_scripts/01_deploy_contract.sh
> ./shell_scripts/01_deploy_contract.sh
```

All deployed contract address can be found in `env/contract.env`.

All anvil develop accounts and contract address will be exported as environment variables in current shell. Variable names can be found in files in `env` directory. steward address of registra was set to `$ANVIL_ADDR_2`

## Impersonate account and transfer USDC and DAI to test account

```shell
> chmod +x shell_scripts/02_impersonate_accounts.sh
> ./shell_scripts/02_impersonate_accounts.sh
```

After script,

- 1,000,000 USDC had transfered to `$ANVIL_ADDR_1` and `$ANVIL_ADDR_2`
- 1,000,000 DAI had transfered to `$ANVIL_ADDR_1` and `$ANVIL_ADDR_2`

## Mint a position with account `$ANNVIL_ADDR_1`

```shell
> chmod +x shell_scripts/03_mint_position.sh
> ./shell_scripts/03_mint_position.sh
```

After script,

- position(`1`) would be created, the owner is `$ANVIL_ADDR_1`
- 1000 USDC would have deposited in position(`1`)

Query position assets with follow command:

```shell
>source env/contracts.env
>cast call $AMP_BOOKKEEPER "getERC20Stats(uint)(address[],uint[],uint[],uint[])" 1
```

## Provide liquidity to PUD/USDC pool

```shell
> chmod +x shell_scripts/04_provide_liquidity.sh
> ./shell_scripts/04_provide_liquidity.sh
```

## Approve operator

```shell
> chmod +x shell_scripts/05_approve_operator.sh
> ./shell_scripts/05_approve_operator.sh
```

## Set anvil node mining interval

```shell
> cast rpc evm_setIntervalMining 1
```
