#!/bin/bash

echo "Running prysm"

set -eu

source vars.sh

NBC_DATADIR="/root/multinet/repo/deposits/nimbus-0"

MULTINET_POD_NAME=${MULTINET_POD_NAME:-prysm-0}
PRY_DATADIR="/root/multinet/repo/deposits/$MULTINET_POD_NAME"

SRCDIR=${PRYSM_PATH:-"prysm"}

set -x

cd "$SRCDIR"

rm -rf /tmp/beacon-prysm

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
  --datadir=/tmp/beacon-prysm \
  --pprof \
  --rpc-host=0.0.0.0 \
  --rpc-port=4000 \
  --http-web3provider=http://34.78.227.45:8545/ \
  --verbosity=debug \
  --interop-eth1data-votes \
  --chain-config-file=$TESTNET_DIR/config.yaml \
  --deposit-contract=0x8A04d14125D0FDCDc742F4A05C051De07232EDa4 \
  --interop-genesis-state=$TESTNET_DIR/genesis.ssz \
  --accept-terms-of-use &

sleep 5

bazel run //validator --define=ssz=$SPEC_VERSION -- \
  --chain-config-file=$TESTNET_DIR/config.yaml \
  --disable-accounts-v2=true \
  --verbosity=debug \
  --accept-terms-of-use \
  --wallet-dir=$PRY_DATADIR/prysm/wallets
