#!/bin/bash

LOG_FILE="/usr/capture/rekey-setup.log"
exec > "$LOG_FILE" 2>&1

swanctl --rekey --child=myconn
swanctl --list-sas