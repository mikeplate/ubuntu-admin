#!/bin/bash
#
# Update Nginx with Passenger to latest version. For Ubuntu servers.

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit 1
fi

# Determine the current stable version of nginx
HTML="$(wget -qO- http://nginx.org/en/download.html)"
if [[ ! $HTML =~ \<h4\>Stable\ version.* ]]; then
    echo 'Cannot determine nginx version, did not find heading'
    exit 1
fi
HTML="${BASH_REMATCH[0]}"
if [[ ! $HTML =~ nginx-([0-9.]+)\< ]]; then
    echo 'Cannot determine nginx version, did not find version number'
    exit 1
fi
NGINXVER="${BASH_REMATCH[1]}"
if [ ${#NGINXVER} -lt 5 ]; then
    echo "Cannot determine nginx version, number $NGINXVER is too short"
    exit 1
fi

# Determine the version of installed nginx
USING_NGINXVER=$(nginx -v 2>&1)
USING_NGINXVER=${USING_NGINXVER#*/}

# Ensure Passenger is up to date and get its version
gem update passenger sinatra sinatra-reloader
PASSENGERVER=$(gem list | grep passenger)
[[ $PASSENGERVER =~ [0-9.]+ ]]
PASSENGERVER=$BASH_REMATCH
if [ -z $PASSENGERVER ]; then
    echo 'Cannot determine Passenger version'
    exit 1
fi

# Determine the Passenger version compiled into installed nginx
USING_PASSENGERVER=$(nginx -V 2>&1)
[[ $USING_PASSENGERVER =~ passenger-([0-9.]+) ]]
USING_PASSENGERVER=${BASH_REMATCH[1]}
if [ -z $USING_PASSENGERVER ]; then
    echo 'Cannot determine Passenger version compiled with nginx'
    exit 1
fi

# Check if we need to update, if any version has changed
if [ $NGINXVER == $USING_NGINXVER -a $PASSENGERVER == $USING_PASSENGERVER ]; then
    echo 'No new version available'
    exit
fi

# Get the path to the nginx extension for Passenger
PASSENGERPATH="$(gem content passenger | grep -Ei '/ext/nginx/Configuration.c' | sed 's/\/ext\/nginx\/Configuration.c//')"
if [ ${#PASSENGERPATH} -lt 10 ]; then
    echo "Cannot determine Passenger location, path $PASSENGERPATH is too short"
    exit 1
fi

# Download and unzip nginx
if [ -d tmp/nginx ]; then
    rm -rf tmp/nginx
    mkdir tmp/nginx
fi
cd tmp/nginx
wget http://nginx.org/download/nginx-$NGINXVER.tar.gz
tar xvf nginx-$NGINXVER.tar.gz
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
    --with-http_uwsgi_module \
    --with-http_stub_status_module \
    --with-http_gzip_static_module \
    --with-http_ssl_module \
    --add-module=$PASSENGERPATH/ext/nginx
make
if [ $? -ne 0 ]; then
    echo 'Failed to make nginx'
    exit $?
fi
cd ../../..
stop nginx
cp /usr/sbin/nginx tmp/nginx/nginx.backup
cp tmp/nginx/nginx-$NGINXVER/objs/nginx /usr/sbin/nginx

# Update basic nginx configuration
cp /etc/nginx/nginx.conf tmp/nginx/nginx.conf.backup
sed -E -e "s!passenger_root .+;!passenger_root $PASSENGERPATH;!" \
    -e "s!passenger_ruby .+;!passenger_ruby $(which ruby);!" \
    -i /etc/nginx/nginx.conf

# Start nginx again
start nginx
if [ $? -ne 0 ]; then
    echo 'nginx failed to start after update'
    echo 'Restoring old files and try to start nginx again'

    # Restore old files and try to start again
    cp tmp/nginx/nginx.backup /usr/sbin/nginx
    cp tmp/nginx/nginx.conf.backup /etc/nginx/nginx.conf
    start nginx
    exit
fi

echo 'Update completed successfully'

