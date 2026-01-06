# `Kiichain` mainnet Details

- **Chain-ID**: `kiichain_1783-1`
- **denom**: `akii`
- **decimals**: `18`
- **Spawn time**: `2025-12-05T12:00:00Z`
- **SHA256 for genesis file**: `67fcfa1af8dedbbb9036b3651dfd4dd353a00f6df2531691d569ea5f743fbf30`

## Endpoints

The following endpoints are exposed:

- `RPC`: https://rpc.kiivalidator.com
- `Rest (LCD)`: https://lcd.kiivalidator.com
- `GRPC`: https://grpc.kiivalidator.com:443
- `JSON-RPC (EVM)`: https://json-rpc.kiivalidator.com
- `WebSocket`: wss://ws.kiivalidator.com/websocket

Persistent peers:

- 4d0c3be48018cf8234faa46d789634f8a811dc5b@p2p-1.kiivalidator.com:26656
- ac58976b16880535d56b2e1fe1f499a3841c4039@p2p-2.kiivalidator.com:26656


## How to Join

### Hardware Requirements

- 8 GB RAM
- 1 TB NVME SSD
- 4 Cores x86_64

#### Bash Script

The scripts provided in this repo will install Kiichaind and optionally set up a `Cosmovisor` service with the auto-download feature enabled on your machine.

Run script provided to set up a `kiichaind` service without `Cosmovisor`:

- [join_kiichain.sh](./join_kiichain.sh) will create a `kiichaind` service.
  - Script must be run either as root or from a sudoer account.

Or run the second script provided to set up a `kiichaind` service with `Cosmovisor`:

- [join_kiichain_cv.sh](./join_kiichain_cv.sh) will create a `cosmosvisor-kiichaind` service.
  - Script must be run either as root or from a sudoer account.

### Node manual installation

Install Kiichain binary.

```bash
git clone https://github.com/KiiChain/kiichain.git
cd kiichain
make install
```

After installation please check installed version by running:

`kiichaind version --long`
