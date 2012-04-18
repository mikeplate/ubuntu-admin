#!/bin/bash
#
# Setup PhantomJS, used for headless web testing.

if [ $(id -u) -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

apt-get -y install fontconfig
apt-get -y install ttf-mscorefonts-installer

DESTDIR=/usr/local

wget http://phantomjs.googlecode.com/files/phantomjs-1.5.0-linux-x86_64-dynamic.tar.gz -O /tmp/phantomjs.tar.gz
tar --directory $DESTDIR -xf /tmp/phantomjs.tar.gz
ln -fs $DESTDIR/phantomjs/bin/phantomjs /usr/local/bin/phantomjs
rm /tmp/phantomjs.tar.gz

echo "PhantomJS successfully installed into $DESTDIR/phantomjs"

