#!/bin/bash
echo "$MULTINET_POD_NAME";

rm -rf /root/multinet/repo/data/"$MULTINET_POD_NAME";
mkdir -p /root/multinet/repo/data/"$MULTINET_POD_NAME";
mkdir -p /root/multinet/repo/data/common;

if [ "$MULTINET_POD_NAME" == "teku-catalyst-0" ]; then
  rm /root/multinet/repo/data/common/enodes.txt;
fi

if [ ! -f /root/multinet/repo/data/common/enodes.txt ] && [ "$MULTINET_POD_NAME" == "teku-catalyst-0" ] ; then
  echo "$STATIC_NODES" > /root/multinet/repo/data/common/enodes.txt;
fi

echo "$GENESIS_BODY" > /root/multinet/repo/data/common/genesis.json;
./geth --datadir /root/multinet/repo/data/"$MULTINET_POD_NAME" init /root/multinet/repo/data/common/genesis.json;
./bootnode -nodekeyhex $(cat /root/multinet/repo/data/$MULTINET_POD_NAME/geth/nodekey) -writeaddress > /root/multinet/repo/data/$MULTINET_POD_NAME/enode.txt;
echo $GENESIS_TIME
./teku/bin/teku genesis mock --output-file /root/multinet/repo/data/common/genesis.ssz --eth1-block-hash $ETH_1_BLOCK_HASH --genesis-time $GENESIS_TIME --validator-count $ETH2_VALIDATORS;
FULLENODE=$(echo enode://$(cat /root/multinet/repo/data/$MULTINET_POD_NAME/enode.txt)@$MULTINET_POD_IP:30303);
#echo "waiters are starting";
#
#while  [ ! -f /root/multinet/repo/data/common/enodes.txt ]; do
#  sleep 5;
#done
#
#if grep -q "teku-catalyst" /root/multinet/repo/data/common/enodes.txt; then
#  sed -i -e "s~$MULTINET_POD_NAME~$FULLENODE~g" /root/multinet/repo/data/common/enodes.txt
#fi
#
#while grep -q "teku-catalyst" /root/multinet/repo/data/common/enodes.txt; do
#  sleep 5;
#done
echo "Done";
