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
mysql -u root << EOF
update mysql.user set password = password('$REPLY') where user='root';
flush privileges;
EOF

echo 'MySQL installed successfully'

