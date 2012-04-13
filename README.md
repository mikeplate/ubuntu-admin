# Ubuntu Administration Scripts

This repository contains a collection of Bash scripts for automating the administration of Ubuntu servers.
Note that default locations and settings are set according to my own preferences and might not be the best
for all setups.

## Setup a new web server

Immediately after installing a new server, the following command can be used to setup a new web server:

```bash
sudo ./nginx-setup.sh
```

It will setup the following components:

- Nginx
- Passenger
- Ruby
- Sinatra and a few other gems
- Add a default site on port 80, any host name, as a Ruby+Sinatra app

## Add a new site to the web server

Adding a new site is supported by two scripts depending on if it should be an Ruby+Sinatra app or a php app.
Both scripts take the same arguments and supports copying default files from a template directory to the new
site directory and sets up suitable permissions.

```bash
sudo ./nginx-add-ruby.sh company-site companydomainname.com
sudo ./nginx-add-php.sh other-site otherdomainname.com
```

This script takes two arguments:

- The name of the site, which is used as name for config file and directory
- The domain name that the site is bound to

It will do the following:

- Create the Nginx configuration file
- Create the web site directory and set appropriate permissions
- Copy default files for the new site from a template subdirectory
- Reload Nginx to have the site running immediately

## Add WordPress to a php site

Adding WordPress to a php site, or updating an existing WordPress site to the latest version, can be
performed with the following script:

```bash
./wordpress-update.sh company-site
```

This script takes one argument:

- The name of the site, as specified when the site was created (actually the directory name)

It will do the following:

- Download, unpack and possibly overwrite the WordPress files in the site
- Set permissions so that plugins can be updated in the web admin interface

## MySQL

Installing MySQL can be performed with the following script:

```bash
sudo ./mysql-setup.sh
```

Adding a new database and a user will full permissions to that database, can be performed with the following
script:

```bash
 ./mysql-add.sh mydata atgY!6263HNBa;a
```

This script takes two arguments:

- The name of the database and the user with full permissions to that database (always the same)
- The password for the MySQL user

## License

All scripts are released to the public domain and are free to use and modify for all.
