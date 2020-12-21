#!/bin/bash

echo "Running teku"

set -eu

source vars.sh

NBC_DATADIR="/root/multinet/repo/deposits/nimbus-0"

MULTINET_POD_NAME=${MULTINET_POD_NAME:-teku-0}
TKU_DATADIR="/root/multinet/repo/deposits/$MULTINET_POD_NAME"

SRCDIR=${TEKU_PATH:-"teku"}

set -x

cd "$SRCDIR"

rm -rf /tmp/beacon-teku

# Wait nimbus (bootstrap node)
wait_enr "$NBC_DATADIR/beacon_node.enr"

sleep 2

BOOTNODES_ARG=""
if [[ -f $TESTNET_DIR/bootstrap_nodes.txt ]]; then
  BOOTNODES_ARG="--bootstrap-node=$(cat $TESTNET_DIR/bootstrap_nodes.txt | paste -s -d, -)"
fi

# needs a mock contract or will not like it
# 0x0 did not work

bazel run //beacon-chain --define=ssz=$SPEC_VERSION -- \
  $BOOTNODES_ARG \
  --force-clear-db \
  --datadir=/tmp/beacon-teku \
  --pprof \
  --rpc-host=0.0.0.0 \
  --rpc-port=4000 \
  --http-web3provider=https://mainnet.infura.io/v3/9e53d9a806764e0b9f2dcf5ccf9161a2 \
  --verbosity=debug \
  --interop-eth1data-votes \
  --chain-config-file=$TESTNET_DIR/config.yaml \
  --deposit-contract=0x00000000219ab540356cBB839Cbe05303d7705Fa \
  --interop-genesis-state=$TESTNET_DIR/genesis.ssz \
  --accept-terms-of-use &

sleep 5

bazel run //validator --define=ssz=$SPEC_VERSION -- \
  --chain-config-file=$TESTNET_DIR/config.yaml \
  --disable-accounts-v2=true \
  --verbosity=debug \
  --accept-terms-of-use \
  --wallet-dir=$TKU_DATADIR/prysm/wallets
