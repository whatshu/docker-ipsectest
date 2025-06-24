#!/bin/bash
set -e

# log
exec > /usr/capture/entrypoint.log 2>&1

# tcpdump
tcpdump -i any -U -s 0 -w /usr/capture/output.pcap &

# start charon
CHARON_BIN=/usr/libexec/ipsec/charon
[ -x "$CHARON_BIN" ] || { echo "ERROR: $CHARON_BIN not found"; exit 1; }
"$CHARON_BIN" &
sleep 2

# tunnel setup
rm -f /usr/capture/keys/*
swanctl --load-all
swanctl --initiate --child=myconn
swanctl --list-sas
sleep 10
ip xfrm state > /usr/capture/xfrm_state.txt

# rekey
swanctl --rekey --child=myconn
swanctl --list-sas
sleep 30

echo 'entrypoint.sh end'
