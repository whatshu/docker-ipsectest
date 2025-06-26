#!/bin/bash
set -e

echo 'entrypoint.sh start, clearing old files'
rm -f /usr/capture/keys/*
rm -f /usr/capture/output.pcap
rm -f /usr/capture/*.log

# log
exec > /usr/capture/entrypoint.log 2>&1

# tcpdump
echo 'starting tcpdump'
tcpdump -i any -U -s 0 -w /usr/capture/output.pcap &

# start charon
echo 'starting strongswan charon'
CHARON_BIN=/usr/libexec/ipsec/charon
[ -x "$CHARON_BIN" ] || { echo "ERROR: $CHARON_BIN not found"; exit 1; }
"$CHARON_BIN" &
sleep 2

# tunnel setup
echo 'running tunnel setup'
#   hook 0, tunnel-setup
if [ -f /usr/bin/tunnel-setup.sh ]; then
    chmod +x /usr/bin/tunnel-setup.sh
    /usr/bin/tunnel-setup.sh
else
    echo 'tunnel-setup.sh not found'
fi
sleep 10
ip xfrm state > /usr/capture/xfrm_state.log
#   hook 1, tunnel-test
echo 'running tunnel test'
if [ -f /usr/bin/tunnel-test.sh ]; then
    chmod +x /usr/bin/tunnel-test.sh
    /usr/bin/tunnel-test.sh
else
    echo 'tunnel-test.sh not found'
fi

# rekey
echo 'running rekey setup'
#   hook 2, rekey-setup
if [ -f /usr/bin/rekey-setup.sh ]; then
    chmod +x /usr/bin/rekey-setup.sh
    /usr/bin/rekey-setup.sh
else
    echo 'rekey-setup.sh not found'
fi
sleep 10
#   hook 3, rekey-test
echo 'running rekey test'
if [ -f /usr/bin/rekey-test.sh ]; then
    chmod +x /usr/bin/rekey-test.sh
    /usr/bin/rekey-test.sh
else
    echo 'rekey-test.sh not found'
fi

sleep 10
echo 'entrypoint.sh end'
