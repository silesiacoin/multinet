#!/bin/bash
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
