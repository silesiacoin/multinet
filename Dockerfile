FROM silesiacoin/multinet-prysm:v17 as Builder

COPY ./scripts/run_prysm.sh /root/multinet/repo
RUN chmod +x /root/multinet/repo/run_prysm.sh
RUN chmod +x /root/multinet/repo/wait_for.sh
