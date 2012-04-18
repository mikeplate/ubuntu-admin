#!/bin/bash
#
# Setup Ubuntu system.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Setup time synchronization
tee /etc/cron.daily/ntpdate > /dev/null << EOF
ntpdate ntp.ubuntu.com
EOF
chmod 755 /etc/cron.daily/ntpdate
ntpdate ntp.ubuntu.com

