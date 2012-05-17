#!/bin/bash
#
# Setup MySQL.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Ask for root password
read -s -p 'Specify password to set for MySQL root account: '
echo ''

# Install MySQL
echo 'Installing MySQL packages'
DEBIAN_FRONTEND=noninteractive apt-get -yq install mysql-server >> tmp/logfile
if [ $? -ne 0 ]; then
    echo 'Failed to install mysql-server package'
    exit $?
fi

# Set root password
mysql -u root << EOF
update mysql.user set password = password('$REPLY') where user='root';
flush privileges;
EOF
if [ $? -ne 0 ]; then
    echo 'Failed to set root password for MySQL'
    exit $?
fi

# Remember password for system root user to that 'sudo -H' will give access
cat > /root/.my.cnf << EOF
[client]
user = root
password = $REPLY
EOF
chown root:root /root/.my.cnf
chmod 600 /root/.my.cnf

# Set up backup, assuming scheduling done by ubuntu-setup.sh
if [ -d /usr/local/backup ]; then
    echo 'Create backup script'
    cp mysql-backup.sh /usr/local/backup/mysql-backup.sh
    chmod 750 /usr/local/backup/mysql-backup.sh
else
    echo 'No backup directory found. Backup script not created.'
fi

# Get version for display purposes
MYSQLVER=$(mysqld --version)
[[ $MYSQLVER =~ Ver\ ([0-9.]+) ]]
MYSQLVER=${BASH_REMATCH[1]}

echo "MySQL version $MYSQLVER installed successfully"

