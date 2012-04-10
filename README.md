# Ubuntu Administration Scripts

This repository contains a collection of Bash scripts for automating the administration of Ubuntu servers.
Note that default locations and settings are set according to my own preferences and might not be the best
for all setups.

## Setup a new web server

Immediately after installing a new server, the following command can be used to setup a new web server:

sudo nginx-setup.sh

It will setup the following components:

- Nginx
- Passenger
- Ruby
- Sinatra and a few other gems
- Add a default site with server name "localhost"

## Add a new site to the web server

sudo nginx-add-ruby.sh company-site companydomainname.com

This script takes two arguments:

- The name of the site, which is used for file and directory names.
- The domain name that the site responds to.

It will do the following:

- Create the Nginx configuration file
- Create the web site directory and set appropriate permissions
- Copy default files for the new site from a template subdirectory

## License

All scripts are released to the public domain and are free to use and modify for all.

