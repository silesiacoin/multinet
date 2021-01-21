#!/bin/bash

FULLENODE=$(echo enode://$(cat /root/multinet/repo/data/$MULTINET_POD_NAME/enode.txt)@$MULTINET_POD_IP:30303);
echo "waiters are starting";

while  [ ! -f /root/multinet/repo/data/common/enodes.txt ]; do
  sleep 5;
done

echo "Catalyst grep on $MULTINET_POD_NAME"

if grep -q "teku-catalyst" /root/multinet/repo/data/common/enodes.txt; then
  sed -i -e "s~$MULTINET_POD_NAME~$FULLENODE~g" /root/multinet/repo/data/common/enodes.txt
fi

while grep -q "teku-catalyst" /root/multinet/repo/data/common/enodes.txt; do
  sleep 5;
done

cp /root/multinet/repo/data/common/UTC--2021-01-18T17-33-56.364337282Z--3a98976b3a0261038aac8dee8d47a225e2f831c3 /root/multinet/repo/data/$MULTINET_POD_NAME/keystore/

cp /root/multinet/repo/data/common/enodes.txt /root/multinet/repo/data/$MULTINET_POD_NAME/geth/static-nodes.json
cp /root/multinet/repo/data/common/enodes.txt /root/multinet/repo/data/$MULTINET_POD_NAME/geth/trusted-nodes.json
./geth --rpc --rpcapi net,eth,eth2,web3,personal,admin,db,debug,miner,shh,txpool --etherbase 0x1000000000000000000000000000000000000000 --datadir /root/multinet/repo/data/$MULTINET_POD_NAME --rpccorsdomain "*" --rpcaddr "$MULTINET_POD_IP" --verbosity 5 --ethstats "$MULTINET_POD_NAME:$CATALYST_STATS_LOGIN_SECRET@$CATALYST_STATS_HOST:80" --unlock 0 --password "/root/multinet/repo/data/common/node.pwds" --allow-insecure-unlock --txpool.processtxs
echo "Done";
