#!/bin/bash
#
# Setup PostgreSQL.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Install PostgreSQL
apt-get -yq install postgresql
if [ $? -ne 0 ]; then
    echo 'Failed to install postgresql package'
    exit $?
fi

# Get version for display purposes
PSQLVER=$(psql --version)
[[ $PSQLVER =~ [0-9.]+ ]]
PSQLVER=$BASH_REMATCH

echo "PostgreSQL version $PSQLVER installed successfully"

