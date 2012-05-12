#!/bin/bash
#
# Add a new database to MySQL.

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
    echo 'Syntax: mysql-add.sh <database-name> <user-name> [<password>]'
    exit
fi
DB_NAME=$1
USER_NAME=$2
USER_PASSWORD=$3

# Create database if it does not exist
mysql --batch --skip-column-names -e 'show databases;' | grep ^$DB_NAME$ > /dev/null
if [ $? -ne 0 ]; then
    mysql -e "create database $DB_NAME;"
fi

# Check if user exists
FOUND_USER=$(mysql --batch --skip-column-names -D mysql -e "select User from user where User='$USER_NAME'")
if [[ -z $FOUND_USER && -z $USER_PASSWORD ]]; then
    echo 'User does not exist so you must specify a password to create that user'
    exit 1
fi

# Give user access to database
if [ -z $FOUND_USER ]; then
    mysql -D $DB_NAME -e "grant all privileges on *.* to '$USER_NAME'@'localhost' identified by '$USER_PASSWORD'"
else
    mysql -D $DB_NAME -e "grant all privileges on *.* to '$USER_NAME'@'localhost'"
fi

