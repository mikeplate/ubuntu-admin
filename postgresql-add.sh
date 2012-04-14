#!/bin/bash
#
# Add a new database to PostgreSQL.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Check arguments
if [ $# -ne 2 ]; then
    echo 'Syntax: postgresql-add.sh <database-and-user-name> <password>'
    exit
fi
DB_NAME=$1
USER_NAME=$1
USER_PASSWORD=$2

# Create database
sudo -u postgres psql << EOF
    create database $DB_NAME;
    create user $USER_NAME with password '$USER_PASSWORD';
    grant all privileges on database $DB_NAME to $USER_NAME;
EOF
if [[ $? -ne 0 ]]; then
    echo 'Failed to create database and user in PostgreSQL'
    exit $?
fi

echo 'Created database and user in PostgreSQL'

