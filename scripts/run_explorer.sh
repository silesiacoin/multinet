#!/bin/bash

echo "Running explorer"

set -eu

source vars.sh

sed 's/MULTINET_POD_IP/'"$MULTINET_POD_IP"'/' /app/config.yaml

while true
do
	echo ""
	sleep 1
done
