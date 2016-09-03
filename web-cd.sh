#!/bin/bash
#
# Change directory to the specified web site's root

# Check arguments
if [ $# -ne 1 ]; then
    echo 'Syntax: web-cd.sh <site-name>'
    exit 1
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
echo $DESTDIR
