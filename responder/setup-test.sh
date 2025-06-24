#!/bin/bash

echo 'running setup test'

# set local ip
ip link add dummy0 type dummy
ip addr add 10.2.0.2/24 dev dummy0
ip link set dummy0 up

# normal ping
ping -c 3 10.200.200.2

# ipsec ping
ping -c 3 -I 10.2.0.2 10.1.0.2
