#!/bin/bash
#
# Add a new database to PostgreSQL.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Check arguments
if [ $# -lt 2 ]; then
    echo 'Syntax: postgresql-add.sh <database-name> <user-name> [<password>]'
    exit
fi
DB_NAME=$1
USER_NAME=$2
USER_PASSWORD=$3

# Create the database if it does not exist
sudo -u postgres psql -Atl | grep ^$DB_NAME\| > /dev/null
if [ $? -ne 0 ]; then
    echo "Create database $DB_NAME"
    sudo -u postgres psql -c "create database $DB_NAME;" > /dev/null
    if [ $? -ne 0 ]; then
        echo 'Could not create database'
        exit $?
    fi
    sudo -u postgres psql -c "revoke connect on database $DB_NAME from public;" > /dev/null
    if [ $? -ne 0 ]; then
        echo 'Could not revoke connect privilege for public to new database'
        exit $?
    fi
fi

# Create the user if it does not exist
FOUND_USER=$(sudo -u postgres psql -Atc '\du' | grep ^$USER_NAME\|)
if [[ -z $FOUND_USER && -z $USER_PASSWORD ]]; then
    echo 'User does not exist so you must specify a password to create that user'
    exit 1
fi
if [ -z $FOUND_USER ]; then
    echo "Create user $USER_NAME"
    sudo -u postgres psql -c "create user $USER_NAME with password '$USER_PASSWORD';" > /dev/null
    if [ $? -ne 0 ]; then
        echo 'Could not create user'
        exit $?
    fi
fi

# Give user access to database
echo 'Grant privileges'
sudo -u postgres psql -c "grant all privileges on database $DB_NAME to $USER_NAME;" > /dev/null
if [ $? -ne 0 ]; then
    echo 'Could not grant privileges for user to database'
    exit $?
fi

echo "Database $DB_NAME now exists with access for $USER_NAME in PostgreSQL"

