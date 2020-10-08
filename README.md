# spells-kovan

Staging repo for MakerDAO's kovan executive spells.

### Getting Started

```
$ git clone git@github.com:makerdao/spells-kovan.git
$ dapp update
```

### Build

```
$ make
```

### Test

Set `ETH_RPC_URL` to a Kovan node.

```
$ export ETH_RPC_URL=<Kovan URL>
$ make test
```

### Deploy

Set `ETH_RPC_URL` to a Kovan node and ensure `ETH_GAS` is set to a high enough number to deploy the contract.

```
$ export ETH_RPC_URL=<Kovan URL>
$ export ETH_GAS=8000000
$ export ETH_GAS_PRICE=$(seth --to-wei 3 "gwei")
$ make deploy

```
