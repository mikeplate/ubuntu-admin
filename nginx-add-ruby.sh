#!/bin/bash
#
# Add a new site to Nginx running Ruby and Sinatra.
# Recommends umask 0027 for future file editing.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Check arguments
if [ $# -lt 2 ]; then
    echo 'Syntax: nginx-add-ruby.sh <site-name> <domain>[:<port>] [<user-name>]'
    exit
fi

DESTDIR=/srv/www/$1
SITENAME=$1
THEUSER=$SUDO_USER
THEGROUP=$(groups $SUDO_USER | awk '{print $3}')

# Separate domain name and port from second argument
SITEPORT=${2#*:}
SITEDOMAIN=${2%:*}
if [ "$SITEPORT" == "$SITEDOMAIN" ]; then
    SITEPORT=80
fi

# Create destination directories
mkdir -p "$DESTDIR/public"
if [ $? -ne 0 ]; then
    echo "Could not create destination directory at $DESTDIR"
    exit
fi
mkdir "$DESTDIR/views"
mkdir "$DESTDIR/tmp"

# Create nginx configuration
tee /etc/nginx/sites/$1.conf > /dev/null << EOF
server {
    listen $SITEPORT;
    server_name $SITEDOMAIN;
    access_log /var/log/nginx/$1.access.log;
    root /srv/www/$1/public;
    passenger_enabled on;
    passenger_friendly_error_pages on;
    passenger_set_cgi_param SITE_NAME "$SITENAME";
}
EOF
chmod 0660 /etc/nginx/sites/$1.conf

# Copy template files
cp -R "$(dirname $0)/nginx-ruby-template/." $DESTDIR

# Set file system properties
chown -R $THEUSER:www-data $DESTDIR
chmod -R 0750 $DESTDIR
find $DESTDIR -type d -exec chmod 2750 {} \;
chown www-data:$THEGROUP $DESTDIR/config.ru
chmod 0710 $DESTDIR
chmod 0660 $DESTDIR/config.ru
chmod 0770 $DESTDIR/tmp

# Check that nginx is happy with configuration
nginx -t
if [ $? -ne 0 ]; then
    echo 'Nginx reported error in configuration'
    exit
fi
nginx -s reload

echo "Created site $1 successfully"

