#!/bin/bash
#
# Add a new database to MySQL.

# Check arguments
if [ $# -ne 2 ]; then
    echo 'Syntax: mysql-add.sh <database-and-user-name> <password>'
    exit
fi
DB_NAME=$1
USER_NAME=$1
USER_PASSWORD=$2

# Create database
echo 'Login to MySQL as root'
mysql -u root -p -e "create database $DB_NAME; use $DB_NAME; grant all privileges on *.* to '$USER_NAME'@'localhost' identified by '$USER_PASSWORD'"

