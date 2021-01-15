#!/bin/bash

## This is very dumb, but its the simplest for now
# Since MULTINET_POD_NAME is teku-catalyst-0 `n` is the last identifier
TEKU_NUMBER=$(echo $MULTINET_POD_NAME | grep -Eo '[0-9]{1,4}' )
echo "teku number $TEKU_NUMBER"
INTEROP_START_INDEX=$(($TEKU_NUMBER *  $INTEROP_OWNED_VALIDATOR_COUNT))


echo "starting with Interop index $INTEROP_START_INDEX";
./teku/bin/teku --Xinterop-enabled=true \
--Xinterop-owned-validator-count=$INTEROP_OWNED_VALIDATOR_COUNT \
--network=minimal --p2p-enabled=true --p2p-discovery-enabled=true \
--initial-state /root/multinet/repo/data/common/genesis.ssz \
--eth1-engine http://$MULTINET_POD_IP:8545 \
--rest-api-interface=$MULTINET_POD_IP --rest-api-host-allowlist="*" --rest-api-port=5051 \
--logging=all --rest-api-enabled=true --metrics-enabled=true \
--p2p-discovery-bootnodes=$TEKU_BOOTNODE_ENR \
--Xinterop-owned-validator-start-index $INTEROP_START_INDEX