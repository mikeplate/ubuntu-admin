#!/bin/bash
#
# Setup Ubuntu system.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Ensure we are up to date
echo 'Ensure packages are updated and upgraded'
apt-get -yq update
apt-get -yq install ntpdate
apt-get -yq upgrade

# Setup time synchronization
tee /etc/cron.daily/ntpdate > /dev/null << EOF
ntpdate ntp.ubuntu.com
EOF
chmod 755 /etc/cron.daily/ntpdate
ntpdate ntp.ubuntu.com

# Setup backup script
echo 'Create backup script'
if [ ! -d /usr/local/backup ]; then
    mkdir /usr/local/backup
    chmod 750 /usr/local/backup
fi
cat > /usr/local/backup/backup.sh << EOF
for FILE_NAME in /usr/local/backup/*-backup.sh; do
    echo "\$(date) \$FILE_NAME" >> /usr/local/backup/backup.log
    bash \$FILE_NAME 2>> /usr/local/backup/error.log
done
EOF
chmod u+x /usr/local/backup/backup.sh

crontab -l | grep -q /usr/local/backup/backup.sh
if [ $? -ne 0 ]; then
    crontab -l | (cat; echo '0 1 * * * /usr/local/backup/backup.sh') | crontab -
fi

