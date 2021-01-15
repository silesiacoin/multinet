#!/bin/bash
echo catalyst;
echo "$MULTINET_POD_NAME";

FULLENODE=$(echo enode://$(cat /root/multinet/repo/data/$MULTINET_POD_NAME/enode.txt)@$MULTINET_POD_IP:30303);
echo "waiters are starting";

while  [ ! -f /root/multinet/repo/data/common/enodes.txt ]; do
  sleep 5;
done

if grep -q "teku-catalyst" /root/multinet/repo/data/common/enodes.txt; then
  sed -i -e "s~$MULTINET_POD_NAME~$FULLENODE~g" /root/multinet/repo/data/common/enodes.txt
fi

while grep -q "teku-catalyst" /root/multinet/repo/data/common/enodes.txt; do
  sleep 5;
done

cp /root/multinet/repo/data/common/enodes.txt /root/multinet/repo/data/$MULTINET_POD_NAME/geth/static-nodes.json
cp /root/multinet/repo/data/common/enodes.txt /root/multinet/repo/data/$MULTINET_POD_NAME/geth/trusted-nodes.json
./geth --rpc --rpcapi net,eth,eth2 --etherbase 0x1000000000000000000000000000000000000000 --datadir /root/multinet/repo/data/$(MULTINET_POD_NAME) --rpccorsdomain "*" --rpcaddr "$MULTINET_POD_IP" --verbosity 5 --ethstats "$MULTINET_POD_NAME:$CATALYST_STATS_LOGIN_SECRET@$CATALYST_STATS_HOST:80"
echo "Done";
