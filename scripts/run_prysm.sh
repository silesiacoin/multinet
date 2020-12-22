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

# needs additional flag to connect to l14 from forked repo
# web3provider connects to lukso l14 network https://rpc.l14.lukso.network/

bazel run //beacon-chain --define=ssz=$SPEC_VERSION -- \
  $BOOTNODES_ARG \
  --force-clear-db \
  --datadir=/tmp/beacon-prysm \
  --pprof \
  --rpc-host=0.0.0.0 \
  --rpc-port=4000 \
  --verbosity=debug \
  --interop-eth1data-votes \
  --chain-config-file=$TESTNET_DIR/config.yaml \
  --accept-terms-of-use \
  --l14 \
  --http-web3provider=https://rpc.l14.lukso.network/ \
  --interop-genesis-state=$TESTNET_DIR/genesis.ssz &

sleep 5

WALLET_DIR=$PRY_DATADIR/prysm/wallets

mkdir -p $WALLET_DIR

if [[ ! -f $WALLLET_DIR/password.txt ]]; then
  apt install -y pwgen
  pwgen -B 24 -c 1 -y -n > $WALLET_DIR/password.txt
  bazel run //validator -- \
    wallet create \
    --wallet-dir=$WALLET_DIR \
    --keymanager-kind=derived \
    --wallet-password-file=$WALLET_DIR/password.txt \
    --skip-mnemonic-25th-word-check=false
fi

#It looks like commit in prysm was compatible with this implementation
bazel run //validator --define=ssz=$SPEC_VERSION -- \
  --disable-accounts-v2=true \
  --verbosity=debug \
  --password=$WALLET_DIR/password.txt \
  --wallet-dir=$WALLET_DIR \
  --keymanager=wallet \
  --keymanageropts=$PRY_DATADIR/prysm/keymanager_opts.json

