# Deployment

## BSCLocal

```sh
npx hardhat run script/mock_tokens.js
npx hardhat run script/mock_transfer_tokens.js
```

## Mainnet

```sh
npx hardhat run script/deploy_factory.js

npx hardhat run script/deploy_router.js

npx hardhat run script/create_pairs.js


npx hardhat run script/depoly_bxhtoken.js

npx hardhat run script/depoly_bxhpool.js

npx hardhat run script/depoly_swapmining.js

```

```sh
yarn mainnet:verify
```

```sh
hardhat tenderly:verify --network mainnet ContractName=Address
```

```sh
hardhat tenderly:push --network mainnet ContractName=Address
```
