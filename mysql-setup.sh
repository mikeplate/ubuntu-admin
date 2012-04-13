#!/bin/bash
#
# Setup MySQL.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Install MySQL
export DEBIAN_FRONTEND=noninteractive
apt-get -y install mysql-server

# Set root password
read -s -p 'Specify password to set for root: '
echo ''
mysqladmin -u root password $REPLY

