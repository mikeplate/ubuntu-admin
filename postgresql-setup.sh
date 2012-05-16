#!/bin/bash
#
# Setup PostgreSQL.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Ensure tmp directory exists for log file
if [ ! -d tmp ]; then
    mkdir tmp
fi

# Install PostgreSQL
echo 'Installing PostgreSQL packages'
apt-get -yq install postgresql libpq-dev postgresql-contrib >> tmp/logfile
if [ $? -ne 0 ]; then
    echo 'Failed to install postgresql package'
    exit $?
fi

# Install libraries
echo 'Installing PostgreSQL libraries'
gem install dm-postgres-adapter -q >> tmp/logfile
if [ $? -ne 0 ]; then
    echo 'Failed to install dm-postgres-adapter gem'
    exit $?
fi
apt-get -yq install php5-pgsql >> tmp/logfile
if [ $? -ne 0 ]; then
    echo 'Failed to install php5-pgsql package'
    exit $?
fi

# Set up backup
echo 'Schedule backup'
cp postgresql-backup.sh /usr/local/sbin/postgresql-backup.sh
chmod u+x /usr/local/sbin/postgresql-backup.sh
crontab -l 2> /dev/null | grep -q postgresql-backup.sh
if [ $? -ne 0 ]; then
    crontab -l 2> /dev/null | (cat; echo '45 23 * * * /usr/local/sbin/postgresql-backup.sh') | crontab -
fi

# Get version for display purposes
PSQLVER=$(psql --version)
[[ $PSQLVER =~ [0-9.]+ ]]
PSQLVER=$BASH_REMATCH

echo "PostgreSQL version $PSQLVER installed successfully"

