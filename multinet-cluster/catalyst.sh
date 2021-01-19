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

cp /root/multinet/repo/data/common/enodes.txt /root/multinet/repo/data/teku-catalyst-dev-1/static-nodes.json;
cp /root/multinet/repo/data/common/enodes.txt /root/multinet/repo/data/teku-catalyst-dev-1/trusted-nodes.json
./geth --networkid 1 --rpc --rpcapi net,eth,eth2 --rpcvhosts "*" --etherbase 0x1000000000000000000000000000000000000000 --datadir /root/multinet/repo/data/teku-catalyst-dev-1 --rpccorsdomain "*" --rpcaddr "0.0.0.0" --verbosity 4 --allow-insecure-unlock --ethstats "teku-catalyst-dev-1:VIyf7EjWlR49@catalyst.silesiacoin.com:80"
echo "Done";