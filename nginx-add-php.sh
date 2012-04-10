#!/bin/bash
#
# Add a new site to Nginx running php.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Check arguments
if [ $# -ne 2 ]; then
    echo 'Syntax: nginx-add-php.sh <site-name> <domain>'
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

# Create nginx configuration
tee /srv/www/$1.conf > /dev/null << EOF
server {
    listen 80;
    server_name $2;
    access_log /var/log/nginx/$1.access.log;
    root /srv/www/$1;
    index index.php index.html;

    location ~ .php\$ {
        fastcgi_split_path_info ^(.+\.php)(.*)\$;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $DESTDIR\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF
chmod 0640 /srv/www/$1.conf

# Copy template files
cp -R "$(dirname $0)/nginx-php-template/." $DESTDIR

# Set file system properties correctly
chown -R $MYUSER:www-data $DESTDIR
chmod -R 0750 $DESTDIR

# Check that nginx is happy with configuration
nginx -t
if [ $? -ne 0 ]; then
    echo 'Nginx reported error in configuration'
    # rm /srv/www/$1.conf
    # rm -rf $DESTDIR
    exit
fi

echo "Created site $1 successfully"

