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
  --http-web3provider=https://rpc.l14.lukso.network/ \
  --verbosity=debug \
  --interop-eth1data-votes \
  --chain-config-file=$TESTNET_DIR/config.yaml \
  --l14 \
  --deposit-contract=0xEEBbf8e25dB001f4EC9b889978DC79B302DF9Efd \
  --interop-genesis-state=$TESTNET_DIR/genesis.ssz \
  --accept-terms-of-use &

sleep 5

WALLET_DIR=$PRY_DATADIR/prysm/wallets

mkdir -p $WALLET_DIR

if [[ ! -f $WALLET_DIR/password.txt ]]; then
  apt install -y pwgen
  pwgen -B 24 -c 1 -y -n > $WALLET_DIR/password.txt
  bazel run //validator -- \
    wallet create \
    --wallet-dir=$WALLET_DIR \
    --keymanager-kind=derived \
    --wallet-password-file=$WALLET_DIR/password.txt \
    --skip-mnemonic-25th-word-check=false
fi

sleep 5

bazel run //validator --define=ssz=$SPEC_VERSION -- \
  --chain-config-file=$TESTNET_DIR/config.yaml \
  --disable-accounts-v2=true \
  --verbosity=debug \
  --accept-terms-of-use \
  --wallet-dir=$WALLET_DIR

while true
do
	echo "Press [CTRL+C] to stop.."
	sleep 1
done
