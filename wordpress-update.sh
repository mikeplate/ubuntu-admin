#!/bin/bash
#
# Download latest version of Wordpress and install to site directory

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Check arguments
if [ $# -ne 1 ]; then
    echo 'Syntax: wordpress-update.sh <site-name>'
    exit
fi

# Determine site directory and user
SITENAME=$1
DESTDIR=/srv/www/$SITENAME
SITE_USER=$SUDO_USER
if [ ! -d $DESTDIR ]; then
    DESTDIR=(/srv/www/*/$SITENAME)
    if [ ! -d $DESTDIR ]; then
        echo "Site $SITENAME is not found"
        exit 1
    fi
    SITE_USER=$(echo $DESTDIR | awk -F'/' '{print $4}')
fi
ROOTDIR=$DESTDIR/public
SITE_GROUP='www-data'

# Ensure destination directory exists
if [ ! -d $ROOTDIR ]; then
    echo "Site root directory $ROOTDIR does not exist"
    exit 1
fi

# Check prerequisites
echo 'Install required packages'
apt-get -qy install zip > tmp/logfile

# Download Wordpress
echo 'Download and unpack WordPress'
if [ -d tmp/wordpress ]; then
    rm -rf tmp/wordpress
fi
wget --no-check-certificate -O tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
#if [ $? -ne 0 ]; then
#    echo 'Failed to download latest version of WordPress'
#    exit $?
#fi
cd tmp
tar xf wordpress.tar.gz > logfile
cd ..

# Create backup of current files in directory 
echo 'Create backup of current files in site'
BACKUP_DIR='/srv/www/.backups'
if [ ! -d $BACKUP_DIR ]; then
    mkdir $BACKUP_DIR
    chown root:adm $BACKUP_DIR
    chmod 770 $BACKUP_DIR
fi
TODAY=`date +%F`
zip -qr $BACKUP_DIR/$SITENAME-$TODAY.zip $DESTDIR/*

# Copy all files
echo 'Copy WordPress to site'
cp -r tmp/wordpress/* $ROOTDIR/
rm -rf tmp/wordpress
rm tmp/wordpress.tar.gz

# Set permissions (in case new files added/changed)
chown -R $SITE_USER:$SITE_GROUP $ROOTDIR
chmod -R 0750 $ROOTDIR
find $ROOTDIR -type d -exec chmod 2750 {} \;
chmod -R 0770 $ROOTDIR/wp-content
find $ROOTDIR/wp-content -type d -exec chmod 2770 {} \;

# Apply patches to Wordpress
# This one removes a replacement of -- when saving post content
sed -i 's/'\''--'\''/'\''-_'\''/' $ROOTDIR/wp-includes/formatting.php

echo "Updated Wordpress for site $1 successfully"

