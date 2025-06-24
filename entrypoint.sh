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
if [ -f /usr/bin/setup-test.sh ]; then
    chmod +x /usr/bin/setup-test.sh
    /usr/bin/setup-test.sh
else
    echo 'setup-test.sh not found, skipping setup test'
fi

# rekey
swanctl --rekey --child=myconn
swanctl --list-sas
if [ -f /usr/bin/rekey-test.sh ]; then
    chmod +x /usr/bin/rekey-test.sh
    /usr/bin/rekey-test.sh
else
    echo 'rekey-test.sh not found, skipping rekey test'
fi
sleep 30

echo 'entrypoint.sh end'
