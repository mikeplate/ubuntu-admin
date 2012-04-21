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

# Determine site information. Separate domain name and port from second argument.
SITENAME=$1
SITEPORT=${2#*:}
SITEDOMAIN=${2%:*}
if [ "$SITEPORT" == "$SITEDOMAIN" ]; then
    SITEPORT=80
fi

# Determine site directory and user
if [ $# -eq 2 ]; then
    DESTDIR=/srv/www/$1-$(uuidgen | sed 's/-//g')
else
    # Does user exist?
    id $3 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        DESTDIR=/srv/www/$3-$(uuidgen | sed 's/-//g')
        mkdir -p $DESTDIR
        chmod 0710 $DESTDIR
        useradd --home "$DESTDIR" $3
        DESTDIR=$DESTDIR/$1
    else
        HOMEDIR=$(cat /etc/passwd | grep ^$3: | awk -F':' '{print $6}')
        DESTDIR=$HOMEDIR/$1
    fi
fi

# Create destination directories
mkdir -p "$DESTDIR/public"
mkdir "$DESTDIR/views"
mkdir "$DESTDIR/tmp"

# Create nginx configuration
tee /etc/nginx/sites/$1.conf > /dev/null << EOF
server {
    listen $SITEPORT;
    server_name $SITEDOMAIN;
    access_log /var/log/nginx/$1.access.log;
    root $DESTDIR;
    passenger_enabled on;
    passenger_friendly_error_pages on;
    passenger_set_cgi_param SITE_NAME "$SITENAME";
}
EOF
chmod 0660 /etc/nginx/sites/$1.conf

# Copy template files
cp -R "$(dirname $0)/nginx-ruby-template/." $DESTDIR

# Set or add user for site
if [ $# -eq 2 ]; then
    THEUSER=$SUDO_USER
    THEGROUP=$(groups $SUDO_USER | awk '{print $3}')
else
    THEUSER=$3
    THEGROUP=$(groups $3 | awk '{print $3}')
fi

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

