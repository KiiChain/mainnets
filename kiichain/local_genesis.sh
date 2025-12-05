#!/bin/bash

CHAINID="kiichain_1783-1"
MONIKER="genesis-test"
# Remember to change to other types of keyring like 'file' in-case exposing to outside world,
# otherwise your balance will be wiped quickly
# The keyring test does not require private key to steal tokens from you
KEYRING="test"

LOGLEVEL="info"
# Set dedicated home directory for the kiichaind instance
HOMEDIR="$HOME/.kiichain"

GAS_PRICE=1000000000
KIICHAIND=kiichaind

# Path variables
CONFIG=$HOMEDIR/config/config.toml
APP_TOML=$HOMEDIR/config/app.toml
GENESIS=$HOMEDIR/config/genesis.json
TMP_GENESIS=$HOMEDIR/config/tmp_genesis.json

BASE_GENESIS=genesis.json

# used to exit on first error (any non-zero exit code)
set -e

# Remove the previous folder
rm -rf "$HOMEDIR"

# Set client config
$KIICHAIND config set client chain-id "$CHAINID" --home "$HOMEDIR"
$KIICHAIND config set client keyring-backend "$KEYRING" --home "$HOMEDIR"

# myKey address 0x7cb61d4117ae31a12e393a1cfa3bac666481d02e | kii10jmp6sgh4cc6zt3e8gw05wavvejgr5pwfe2u6n
VAL_KEY="mykey"
VAL_MNEMONIC="gesture inject test cycle original hollow east ridge hen combine junk child bacon zero hope comfort vacuum milk pitch cage oppose unhappy lunar seat"

# dev0 address 0xc6fe5d33615a1c52c08018c47e8bc53646a0e101 | kii1cml96vmptgw99syqrrz8az79xer2pcgpul2fsy
USER1_KEY="dev0"
USER1_MNEMONIC="copper push brief egg scan entry inform record adjust fossil boss egg comic alien upon aspect dry avoid interest fury window hint race symptom"

# Import keys from mnemonics
echo "$VAL_MNEMONIC" | $KIICHAIND keys add "$VAL_KEY" --recover --keyring-backend "$KEYRING" --home "$HOMEDIR"
echo "$USER1_MNEMONIC" | $KIICHAIND keys add "$USER1_KEY" --recover --keyring-backend "$KEYRING" --home "$HOMEDIR"

# Set moniker and chain-id for the example chain (Moniker can be anything, chain-id must be an integer)
$KIICHAIND init $MONIKER -o --chain-id "$CHAINID" --home "$HOMEDIR"

# Copy genesis over
cp "$BASE_GENESIS" "$GENESIS"

# Remove existing accounts and balances
jq '.app_state.auth.accounts = []' "$GENESIS" > "$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
jq '.app_state.bank.balances = []' "$GENESIS" > "$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

# Remove existing gentxs
jq '.app_state.genutil.gen_txs = []' "$GENESIS" > "$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

# Remove existing validators
jq '.app_state.staking.validators = []' "$GENESIS" > "$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
jq '.app_state.staking.last_validator_powers = []' "$GENESIS" > "$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

# Empty supply
jq '.app_state.bank.supply = []' "$GENESIS" > "$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

# enable prometheus metrics and all APIs for dev node, substitute chain id
if [[ "$OSTYPE" == "darwin"* ]]; then
	sed -i '' 's/prometheus = false/prometheus = true/' "$CONFIG"
	sed -i '' 's/prometheus-retention-time = 0/prometheus-retention-time  = 1000000000000/g' "$APP_TOML"
	sed -i '' 's/enabled = false/enabled = true/g' "$APP_TOML"
	sed -i '' 's/enable = false/enable = true/g' "$APP_TOML"
	sed -i '' 's/evm-chain-id = 1010/evm-chain-id = 1783/g' "$APP_TOML"
else
	sed -i 's/prometheus = false/prometheus = true/' "$CONFIG"
	sed -i 's/prometheus-retention-time  = "0"/prometheus-retention-time  = "1000000000000"/g' "$APP_TOML"
	sed -i 's/enabled = false/enabled = true/g' "$APP_TOML"
	sed -i 's/enable = false/enable = true/g' "$APP_TOML"
	sed -i 's/evm-chain-id = 1010/evm-chain-id = 1783/g' "$APP_TOML"
fi

# Allocate genesis accounts (cosmos formatted addresses)
$KIICHAIND genesis add-genesis-account "$VAL_KEY" 1000000000000000000000000000akii --keyring-backend "$KEYRING" --home "$HOMEDIR"
$KIICHAIND genesis add-genesis-account "$USER1_KEY" 1000000000000000000000000000akii --keyring-backend "$KEYRING" --home "$HOMEDIR"

# Sign genesis transaction
$KIICHAIND genesis gentx "$VAL_KEY" 100000000000000000000akii --gas-prices ${GAS_PRICE}akii --keyring-backend "$KEYRING" --chain-id "$CHAINID" --home "$HOMEDIR"

# Collect genesis tx
$KIICHAIND genesis collect-gentxs --home "$HOMEDIR"

# Run this to ensure everything worked and that the genesis file is setup correctly
$KIICHAIND genesis validate-genesis --home "$HOMEDIR"

# Start the node
$KIICHAIND start "$TRACE" \
	--log_level $LOGLEVEL \
	--minimum-gas-prices=0.0001akii \
	--home "$HOMEDIR" \
	--json-rpc.api eth,txpool,personal,net,debug,web3 \
	--chain-id "$CHAINID"
