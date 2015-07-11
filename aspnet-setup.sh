#!/bin/bash
#
# Set up ASP.NET 5.0 with Mono
# Source from http://blog.jsinh.in/hosting-asp-net-5-web-application-on-linux/

if [ $(id -u) -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

apt-get -y install make zip unzip curl git libtool autoconf automake build-essential zsh gyp

# Install Mono
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
apt-get update
apt-get -y install mono-complete
mono --version

# Prepare som certificates for https downloading
yes | certmgr -ssl -m -v https://go.microsoft.com
yes | certmgr -ssl -m -v https://nugetgallery.blob.core.windows.net
yes | certmgr -ssl -m -v https://myget.org
yes | certmgr -ssl -m -v https://nuget.org
yes | certmgr -ssl -m -v https://www.myget.org/F/aspnetvnext/
mozroots --import --sync --quiet

# Install Libuv
LIBUV_VERSION="1.6.1"
curl -sSL https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src
cd /usr/local/src/libuv-$LIBUV_VERSION
sh autogen.sh
./configure
make
make install
rm -rf /usr/local/src/libuv-$LIBUV_VERSION && cd ~/
ldconfig

# Install .NET tools
curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh | DNX_BRANCH=dev sh && source ~/.dnx/dnvm/dnvm.sh
dnvm upgrade
dnvm list

echo "ASP.NET 5.0 finished installing"

