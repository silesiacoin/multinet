FROM silesiacoin/eth2-beaconchain-explorer:v3 as Builder

COPY ./scripts/run_explorer.sh /root/multinet/repo
RUN chmod +x /root/multinet/repo/run_explorer.sh
