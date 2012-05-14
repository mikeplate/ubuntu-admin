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

# Ensure backup location exists
if [ ! -d /var/backups/mysql ]; then
    mkdir -p /var/backups/mysql
    chown root:root /var/backups/mysql
    chmod 700 /var/backups/mysql
fi

# Find all databases
ALL=$(mysql -Bse 'show databases')
for DB_NAME in $ALL; do
    if [ -f /var/backups/mysql/$DB_NAME.gz ]; then
        cp /var/backups/mysql/$DB_NAME.gz /var/backups/mysql/$DB_NAME-2.gz
    fi
    mysqldump --single-transaction $DB_NAME | gzip > /var/backups/mysql/$DB_NAME.gz
    chown root:root /var/backups/mysql/$DB_NAME.gz
    chmod 600 /var/backups/mysql/$DB_NAME.gz
done

