#!/bin/bash
#
# Setup Ubuntu system.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

echo 'Setup file browser Nautilus'
apt-get -yq install nautilus-open-terminal nautilus-actions

# Reload any changes to Nautilus
nautilus -q

echo 'Install applications'
apt-get -yq install compizconfig-settings-manager

echo 'Finished'

