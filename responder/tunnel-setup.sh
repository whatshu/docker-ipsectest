#!/bin/bash

LOG_FILE="/usr/capture/tunnel-setup.log"
exec > "$LOG_FILE" 2>&1

swanctl --load-all
swanctl --initiate --child=myconn
