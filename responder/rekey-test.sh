#!/bin/bash

LOG_FILE="/usr/capture/rekey-test.log"
exec > "$LOG_FILE" 2>&1

echo 'running rekey test'

# normal ping
ping -c 3 10.200.200.2

# ipsec ping
ping -c 3 -I 10.2.0.2 10.1.0.2
