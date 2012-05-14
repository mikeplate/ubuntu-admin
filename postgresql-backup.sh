#!/bin/bash
#
# Backup PostgreSQL databases.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Ensure backup location exists
if [ ! -d /var/backups/postgresql ]; then
    mkdir -p /var/backups/postgresql
    chown root:root /var/backups/postgresql
    chmod 700 /var/backups/postgresql
fi

# Find all databases
ALL=$(sudo -u postgres psql -Atl | grep \| | cut -d\| -f1)
for DB_NAME in $ALL; do
    if [ ! $DB_NAME == 'template0' ]; then
        if [ -f /var/backups/postgresql/$DB_NAME.gz ]; then
            cp /var/backups/postgresql/$DB_NAME.gz /var/backups/postgresql/$DB_NAME-2.gz
        fi
        sudo -u postgres pg_dump $DB_NAME | gzip > /var/backups/postgresql/$DB_NAME.gz
        chown root:root /var/backups/postgresql/$DB_NAME.gz
        chmod 600 /var/backups/postgresql/$DB_NAME.gz
    fi
done

