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

DESTDIR=/srv/www/$1
SITENAME=$1
MYUSER=$SUDO_USER
MYGROUP=$(groups $SUDO_USER | awk '{print $3}')

# Ensure destination directory exists
if [ ! -d $DESTDIR ]; then
    echo "Site directory $DESTDIR does not exist"
    exit
fi

# Check prerequisites
apt-get -y install zip

# Download Wordpress
if [ -d tmp/wordpress ]; then
    rm -rf tmp/wordpress
fi
wget -O tmp/wordpress.tar.gz http://wordpress.org/latest.tar.gz
if [ $? -ne 0 ]; then
    echo 'Failed to download latest version of WordPresss'
    exit
fi
cd tmp
tar xvf wordpress.tar.gz
cd ..

# Create backup of current files in directory 
if [ ! -d /srv/www/backup ]; then
    mkdir /srv/www/backup
fi
TODAY=`date +%F`
zip -r /srv/www/backup/$1-$TODAY.zip $DESTDIR/*

# Copy all files and set permissions
if [ -d $DESTDIR/wp-content/plugins ]; then
    chown -R $MYUSER:www-data $DESTDIR/wp-content/plugins
fi
cp -r tmp/wordpress/* $DESTDIR/
rm tmp/wordpress.tar.gz
chown -R $MYUSER:www-data $DESTDIR/
chmod -R 770 $DESTDIR/wp-content/plugins

# Apply patches to Wordpress
sed -i 's/'\''--'\''/'\''-_'\''/' $DESTDIR/wp-includes/formatting.php

echo "Updated Wordpress for site $1 successfully"

