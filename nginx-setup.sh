#!/bin/bash
#
# Setup Nginx with Passenger for running Ruby and Sinatra. Tested on Ubuntu servers.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Create temporary directory
if [ ! -d tmp ]; then
    mkdir tmp
fi

# Determine the current stable version of nginx
echo 'Get nginx version from web site'
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

# Install Ruby
echo 'Install ruby1.9.1-full'
apt-get install -yq ruby1.9.1-full >> tmp/logfile
if [ $? -ne 0 ]; then
    echo 'Could not install ruby1.9.1-full'
    exit
fi

# Install required packages for building nginx
echo 'Install other packages for building'
apt-get install -yq build-essential autotools-dev libcurl4-gnutls-dev libpcre3-dev libssl-dev zlib1g-dev >> tmp/logfile
if [ $? -ne 0 ]; then
    echo 'Could not install all packages for building nginx'
    exit
fi

# Install Passenger and get the path to the nginx extension
echo 'Install Passenger'
gem install passenger -q
PASSENGERPATH="$(gem content passenger | grep -Ei '/ext/nginx/Configuration.c' | sed 's/\/ext\/nginx\/Configuration.c//')"
if [ ${#PASSENGERPATH} -lt 10 ]; then
    echo "Cannot determine Passenger location, path $PASSENGERPATH is too short"
    exit
fi

# Install other ruby gems
echo 'Install some Ruby gems'
RUBYGEMS=( sinatra sinatra-reloader rack-debug sass json )
for gemname in "${RUBYGEMS[@]}"; do
    gem install $gemname -q
    if [ $? -ne 0 ]; then
        echo "Could not install Rubygem $gemname."
        exit
    fi
done

# Install packages for php
echo 'Install php5'
apt-get install -yq php5 php5-fpm php5-mysql >> tmp/logfile
if [ $? -ne 0 ]; then
    echo 'Could not install all packages for php'
    exit
fi
sed -e 's|listen = 127.0.0.1:9000|listen = /var/run/php5-fpm.sock|' -i /etc/php5/fpm/pool.d/www.conf
/etc/init.d/php5-fpm restart

# Download and unzip nginx
echo 'Download and build nginx'
if [ ! -d tmp/nginx ]; then
    mkdir -p tmp/nginx
fi
cd tmp/nginx
wget -q http://nginx.org/download/nginx-$NGINXVER.tar.gz
tar -xf nginx-$NGINXVER.tar.gz
cd nginx-$NGINXVER

# Configure and build nginx
./configure \
    --prefix=/var/lib/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --user=www-data \
    --lock-path=/var/lock/nginx.lock \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --without-http_uwsgi_module \
    --with-http_stub_status_module \
    --with-http_gzip_static_module \
    --with-http_ssl_module \
    --add-module=$PASSENGERPATH/ext/nginx >> tmp/logfile
if [ $? -ne 0 ]; then
    echo 'Nginx configure script failed'
    exit $?
fi
make >> tmp/logfile
if [ $? -ne 0 ]; then
    echo 'Nginx make failed'
    exit $?
fi
cp objs/nginx /usr/sbin/nginx

# Setup basic nginx configuration
if [ ! -d /etc/nginx ]; then
    mkdir /etc/nginx
    chown root:adm /etc/nginx
    chmod 0770 /etc/nginx
fi
cp conf/mime.types /etc/nginx/mime.types
tee /etc/nginx/nginx.conf > /dev/null << EOF
user www-data;
worker_processes 2;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    passenger_root $PASSENGERPATH;
    passenger_ruby $(which ruby);
    passenger_log_level 1;
    passenger_debug_log_file /var/log/nginx/passenger.log;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_names_hash_bucket_size 64;
    client_max_body_size 20m;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_disable "msie6";

    include /etc/nginx/sites/*.conf;
}
EOF
tee /etc/nginx/fastcgi_params > /dev/null << EOF
fastcgi_param	QUERY_STRING		\$query_string;
fastcgi_param	REQUEST_METHOD		\$request_method;
fastcgi_param	CONTENT_TYPE		\$content_type;
fastcgi_param	CONTENT_LENGTH		\$content_length;

fastcgi_param	SCRIPT_FILENAME		\$request_filename;
fastcgi_param	SCRIPT_NAME		    \$fastcgi_script_name;
fastcgi_param	REQUEST_URI		    \$request_uri;
fastcgi_param	DOCUMENT_URI		\$document_uri;
fastcgi_param	DOCUMENT_ROOT		\$document_root;
fastcgi_param	SERVER_PROTOCOL		\$server_protocol;

fastcgi_param	GATEWAY_INTERFACE	CGI/1.1;
fastcgi_param	SERVER_SOFTWARE		nginx/\$nginx_version;

fastcgi_param	REMOTE_ADDR		\$remote_addr;
fastcgi_param	REMOTE_PORT		\$remote_port;
fastcgi_param	SERVER_ADDR		\$server_addr;
fastcgi_param	SERVER_PORT		\$server_port;
fastcgi_param	SERVER_NAME		\$server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param	REDIRECT_STATUS		200;
EOF

# Setup the nginx files environment
if [ ! -d /etc/nginx/sites ]; then
    mkdir /etc/nginx/sites
    chown root:adm /etc/nginx/sites
    chmod 0770 /etc/nginx/sites
fi
if [ ! -d /var/log/nginx ]; then
    mkdir /var/log/nginx
    chown www-data:adm /var/log/nginx
    chmod 0770 /var/log/nginx
fi
if [ ! -d /var/lib/nginx ]; then
    mkdir /var/lib/nginx
fi
if [ ! -d /srv/www ]; then
    mkdir -p /srv/www
fi
chown root:root /srv/www
chmod 0751 /srv/www

# Setup the nginx service environment
tee /etc/init/nginx.conf > /dev/null << EOF
description "nginx http daemon"
start on runlevel [2]
stop on runlevel [016]
console output

exec /usr/sbin/nginx -g "daemon off;"
respawn
EOF
start nginx
if [ $? -ne 0 ]; then
    echo 'Nginx did not start'
    exit
fi
cd ../../..

# Create the default web site
if [ -f ./nginx-add-ruby.sh ]; then
    ./nginx-add-ruby.sh default _
fi

echo 'Setup completed successfully'

