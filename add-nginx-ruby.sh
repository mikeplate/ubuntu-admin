#!/bin/bash
#
# Add a new site to Nginx running Ruby and Sinatra.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Check arguments
if [ $# -ne 2 ]; then
    echo 'Syntax: add-nginx-ruby.sh <site-name> <domain>'
    exit
fi

DESTDIR=/srv/www/$1
MYUSER=$SUDO_USER
MYGROUP=$(groups $SUDO_USER | awk '{print $3}')

# Create destination directories
mkdir $DESTDIR
if [ $? -ne 0 ]; then
    echo "Could not create destination directory at $DESTDIR"
    exit
fi
mkdir $DESTDIR/public
mkdir $DESTDIR/views
mkdir $DESTDIR/tmp

# Create nginx configuration
tee /srv/www/$1.conf > /dev/null << EOF
server {
    listen 80;
    server_name $2;
    access_log /var/log/nginx/$1.access.log;
    root /srv/www/$1/public;
    passenger_enabled on;
    passenger_friendly_error_pages on;
}
EOF
chmod 0640 /srv/www/$1.conf

# Copy template files
cp -R "$(dirname $0)/nginx-ruby-template/." $DESTDIR

# Set file system properties correctly
chown -R $MYUSER:www-data $DESTDIR
chmod -R 0750 $DESTDIR
chown www-data:$MYGROUP $DESTDIR/config.ru
chmod 0660 $DESTDIR/config.ru

# Check that nginx is happy with configuration
nginx -t
if [ $? -ne 0 ]; then
    echo 'Nginx reported error in configuration'
    # rm /srv/www/$1.conf
    # rm -rf $DESTDIR
    exit
fi

echo "Created site $1 successfully"

