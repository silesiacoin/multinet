#!/bin/bash

## This is very dumb, but its the simplest for now
# Since MULTINET_POD_NAME is teku-catalyst-0 `n` is the last identifier
TEKU_NUMBER=$(echo $MULTINET_POD_NAME | grep -Eo '[0-9]{1,4}' )
echo "teku number $TEKU_NUMBER"
INTEROP_START_INDEX=$(($TEKU_NUMBER *  $INTEROP_OWNED_VALIDATOR_COUNT))

echo "Waiting for catalyst to be up, no enodes.txt yet"

## Lock for enodes creation
while  [ ! -f /root/multinet/repo/data/common/enodes.txt ]; do
  sleep 5;
done

echo "Waiting for catalyst to be up, enodes.txt not sed'ed yet"
## Lock for enodes registery on catalyst side
while grep -q "teku-catalyst" /root/multinet/repo/data/common/enodes.txt; do
  sleep 5;
done

yes | apt install curl;
yes | apt install jq;

WAIT_FOR_BOOTNODE=true;

TEKU_BOOTNODE_ENR=enr:-KG4QLsrN3KDJILIds0VdLhke1hS3IPDfyT6Ht9moJ98alqQHyuGGcWouNI1eZkqnu2_GhoEAID4vmgZF7kgxplWXt8DhGV0aDKQUmfZxgAAAAH__________4JpZIJ2NIJpcIQKAAAOiXNlY3AyNTZrMaECHUus3zWMIQA3Zebysp9d_cXk6ncpGszUqybmiKd6kVqDdGNwgiMog3VkcIIjKA;

if [ "$MULTINET_POD_NAME" != "teku-catalyst-0" ]; then
  while [ $WAIT_FOR_BOOTNODE ]; do
    TEKU_BOOTNODE_ENR=$(curl -s http://bootstrap:5051/eth/v1/node/identity | jq -r '.data.enr')
    echo $TEKU_BOOTNODE_ENR;
      if echo $TEKU_BOOTNODE_ENR | grep enr; then
        WAIT_FOR_BOOTNODE=false;
        break;
      fi
    echo Waiting for bootnode to be up;
    sleep 5;
  done
fi



echo "starting with Interop index $INTEROP_START_INDEX";

./teku/bin/teku --Xinterop-enabled=true \
--Xinterop-owned-validator-count=$INTEROP_OWNED_VALIDATOR_COUNT \
--network=minimal \
--p2p-enabled=true \
--p2p-discovery-enabled=true \
--initial-state /root/multinet/repo/data/common/genesis.ssz \
--eth1-engine http://$MULTINET_POD_IP:8545 \
--rest-api-interface=$MULTINET_POD_IP \
--rest-api-host-allowlist="*" \
--rest-api-port=5051 \
--logging=all \
--rest-api-enabled=true \
--metrics-enabled=true \
--p2p-discovery-bootnodes=$TEKU_BOOTNODE_ENR \
--Xinterop-owned-validator-start-index "$INTEROP_START_INDEX"
