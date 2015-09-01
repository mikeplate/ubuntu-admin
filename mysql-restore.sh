#!/bin/bash
#
# Backup MySQL databases.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi
if [ $HOME != '/root' ]; then
    echo 'This script is designed to run with /root as home directory (sudo -H)'
    exit
fi

# Check arguments
if [ $# -lt 2 ]; then
    echo 'Syntax: mysql-restore.sh <database-name> <backup-file-name>'
    exit
fi
DB_NAME=$1
FILE_NAME=$2

mysql $DB_NAME < $FILE_NAME

