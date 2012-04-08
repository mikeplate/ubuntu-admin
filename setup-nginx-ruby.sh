#!/bin/bash

# Determine the current stable version of nginx
HTML="$(wget -qO- http://nginx.org/en/download.html)"
if [[ ! $HTML =~ \<h4\>Stable\ version.* ]]; then
    echo 'Cannot determine nginx version, did not find heading'
    exit
fi
HTML="${BASH_REMATCH[0]}"
if [[ ! $HTML =~ nginx-([0-9.]+)\< ]]; then
    echo 'Cannot determine nginx version, did not find version number'
    exit
fi
NGINXVER="${BASH_REMATCH[1]}"
if [ ${#NGINXVER} -lt 5 ]; then
    echo "Cannot determine nginx version, number $NGINXVER is too short"
    exit
fi

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Install Ruby
apt-get install -y ruby1.9.1-full
if [ $? -ne 0 ]; then
    echo 'Could not install ruby1.9.1-full'
    exit
fi

# Install other required packages
apt-get install -y build-essential autotools-dev libcurl4-gnutls-dev libpcre3-dev libssl-dev zlib1g-dev
if [ $? -ne 0 ]; then
    echo 'Could not install all packages'
    exit
fi

# Install Passenger and get the path to the nginx extension
gem install passenger
PASSENGERPATH="$(gem content passenger | grep -Ei '/ext/nginx/Configuration.c' | sed 's/\/Configuration.c//')"

# Download and unzip nginx
if [ ! -d nginx ]; then
    mkdir nginx
fi
cd nginx
wget http://nginx.org/download/nginx-$NGINXVER.tar.gz
tar xvf nginx-$NGINXVER.tar.gz
cd nginx-$NGINXVER

# Configure and build nginx
./configure \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/lock/nginx.lock \
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --without-http_uwsgi_module \
    --with-http_stub_status_module \
    --with-http_gzip_static_module \
    --with-http_ssl_module \
    --add-module=$PASSENGERPATH
make
cp objs/nginx /usr/sbin/nginx

# Setup basic nginx configuration
mkdir /etc/nginx
chown root:root /etc/nginx
chmod 0755 /etc/nginx
cp conf/mime-types /etc/nginx/mime-types
tee /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes 2;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_names_hash_bucket_size 64;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_disable "msie6";

    include /srv/www/*.conf;
}
EOF

# Setup the nginx files environment
mkdir -p /srv/www/default
mkdir /var/log/nginx
chown www-data:adm /var/log/nginx
chmod 0750 /var/log/nginx
mkdir /var/lib/nginx

# Setup the nginx service environment
tee /etc/init/nginx << EOF
description "nginx http daemon"
start on runlevel [2]
stop on runlevel [016]
console owner

exec /usr/sbin/nginx -g "daemon off;"
respawn
EOF

