#!/bin/bash
#
# Download latest version of Wordpress and install to site directory

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Check arguments
if [ $# -lt 1 ]; then
    echo 'Syntax: wordpress-update.sh <site-name> [<user-name>]'
    exit
fi
SITENAME=$1

# Find site directory and set variables for site user and group
if [ $# -eq 1 ]; then
    SITE_USER=$SUDO_USER
    SITE_GROUP=$(groups $SUDO_USER | awk '{print $3}')
    DESTDIR=/srv/www/$1
else
    SITE_USER=$3
    SITE_GROUP=$(groups $2 | awk '{print $2}')
    HOMEDIR=$(cat /etc/passwd | grep ^$2: | awk -F':' '{print $6}')
    DESTDIR=$HOMEDIR/$1
fi
ROOTDIR=$DESTDIR/public

# Ensure destination directory exists
if [ ! -d $ROOTDIR ]; then
    echo "Site root directory $ROOTDIR does not exist"
    exit
fi

# Check prerequisites
echo 'Install required packages'
if [ -d tmp/wordpress ]; then
    rm -rf tmp/wordpress
fi
apt-get -yq install zip >> tmp/logfile

# Download Wordpress
echo 'Download Wordpress'
wget -qO tmp/wordpress.tar.gz http://wordpress.org/latest.tar.gz >> tmp/logfile
if [ $? -ne 0 ]; then
    echo 'Failed to download latest version of WordPresss'
    exit
fi
cd tmp
tar xvf wordpress.tar.gz >> logfile
cd ..

# Create backup of current files in directory 
if [ ! -d /srv/www/backup ]; then
    mkdir /srv/www/backup
fi
TODAY=`date +%F`
zip -r /srv/www/backup/$1-$TODAY.zip $DESTDIR/* >> tmp/logfile

# Copy all files
if [ -d $ROOTDIR/wp-content/plugins ]; then
    chown -R $SITE_USER:www-data $ROOTDIR/wp-content/plugins
fi
cp -r tmp/wordpress/* $ROOTDIR/
rm tmp/wordpress.tar.gz

# Set file system properties
chown -R $SITE_USER:www-data $ROOTDIR/
chmod -R 770 $ROOTDIR/wp-content/plugins

# Apply patches to Wordpress
# This one removes a replacement of -- when saving post content
sed -i 's/'\''--'\''/'\''-_'\''/' $ROOTDIR/wp-includes/formatting.php

echo "Updated Wordpress for site $DESTDIR successfully"

