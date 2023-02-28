# Amplifi demo backend

## Setup a local development evm

```shell
> export INFURA_KEY=<infura_mainnet_api_secrets>
> chmod +x run_anvil.sh
> ./run_anvil.sh
```

## deploy contract to local development evm

```shell
> chmod +x deploy_to_local.sh
> ./deploy_to_local.sh
```

All deployed contract address can be found in `env/contract.env`.

All anvil develop accounts and contract address will be exported as environment variables in current shell. Variable names can be found in files in `env` directory.

After the deployment,

- steward address of registra was set to `$ANVIL_ADDR_9`
- 1,000,000 USDC transfered to `$ANVIL_ADDR_1` and `$ANVIL_ADDR_2`
- 1,000,000 DAI transfered to `$ANVIL_ADDR_1` and `$ANVIL_ADDR_2`
