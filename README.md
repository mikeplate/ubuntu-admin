# Ubuntu Administration Scripts

This repository contains a collection of Bash scripts for automating the administration of Ubuntu servers.
Note that default locations and settings are set according to my own preferences and might not be the best
for all setups.

The parameters that are specified to the scripts are as few as possible. A lot of choices
have already been made inside the script code. One such choice is for all web servers to install both
Ruby and PHP.

These scripts should be regarded as a stepping stone to other automation tools.

## Setup a new Ubuntu server

On a fresh installation of an Ubuntu server, the following command can be used to setup the base
configuration:

```bash
sudo ./ubuntu-setup.sh
```

It will do the following:

- Update and upgrade all packages
- Configure clock syncing by scheduling ntpdate to run

## Setup a new web server

Immediately after installing a new server, the following command can be used to setup a new web server:

```bash
sudo ./nginx-setup.sh
```

It will setup the following components:

- Nginx (build from source, latest stable release)
- Passenger (from standard gem install)
- Ruby 1.9 (from standard Ubuntu package)
- Sinatra and a few other gems (from standard gem install)
- PHP 5 with FPM (from standard Ubuntu package)
- Add a default site on port 80, any host name, as a Ruby+Sinatra app

In order to check for new versions of Nginx and/or Passenger, you can run the following script at any
time. If a new version is available it will download it and rebuild Nginx with Passenger and install
it without changing any other configuration files.

```bash
sudo ./nginx-update.sh
```

### Background

The script will automatically download the source code for the latest version of Nginx stable release
and build it with the Passenger extension that is installed with the gem tool. The setup of Nginx is
quite similar to what you get on Ubuntu with the standard package but with at least two exceptions:

- All site directories are placed under the /srv/www directory
- Site configuration files are stored in /etc/nginx/sites/*.conf (no distinction between sites-available
  and sites-enabled as in the standard package)

## Add a new site to the web server

Adding a new site is supported by two scripts depending on if it should be a Ruby+Sinatra app or a php app.
Both scripts take the same arguments and supports copying default files from a template directory to the new
site directory and sets up suitable permissions.

```bash
sudo ./nginx-add-ruby.sh company companydomainname.com
sudo ./nginx-add-ruby.sh intranet companydomainname.com:8080
sudo ./nginx-add-php.sh other otherdomainname.com
sudo ./nginx-add-php.sh external externalname.com external-user
```

This script takes the following arguments:

- The name of the site, which is used as name for config file and directory
- The domain name that the site is bound to, with an optional port number
- An optional user account under which the web site code should run

It will do the following:

- Create the Nginx configuration file
- Create the web site directory and set appropriate permissions
- Public files for the web site will be placed in subdirectory "public"
- Log files for the web site will be placed in subdirectory "logs"
- Copy default files for the new site from a template subdirectory
- Create a user if such is specified and does not previously exist
- Lock created user into a home directory (chroot) for sftp access to the site
- Setup logging of sftp access
- Reload Nginx to have the site running immediately

For a PHP site with a specified user, the script will create a separate FPM process for running all php
code as that user.

For a Ruby site with a specified user, the script will make sure that the owner of config.ru is that
user and so Passenger will run all Ruby code as that user too.

### Background

The way owners and permissions are set on site directories and files are still under development and
might change in future versions. Right now, the basic settings in this regard is:

- The currently logged in user (you!) is the owner
- The www-data group is the group owner
- The group id bit is set so that new files and directories automatically get www-data as group owner
- The recommended umask when creating new files and directories is 0027 so that www-data does not have
  write permissions to anything that is shouldn't

Note that is setup is something I've come up with myself and I'm not yet sure if it is the perfect setup
both for security reasons and simplicity reasons when developing on the machine.

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
- Set permissions so that plugins can be updated in the web admin interface (if a specific user was
  specified when the PHP site was created, then all files are updatable anyway)

## MySQL

Installing MySQL can be performed with the following command:

```bash
sudo ./mysql-setup.sh
```

Adding a new database and a user will full permissions to that database, can be performed with the following
command. Note that to prevent the password from showing up in Bash history, start the command with a space!

```bash
 ./mysql-add.sh mydata atgY6263HNBaa
```

This script takes two arguments:

- The name of the database and the database user with full permissions to that database (always the same)
- The password for the new MySQL database user

## PostgreSQL

Installing PostgreSQL can be performed with the following command:

```bash
sudo ./postgresql-setup.sh
```

Adding a new database and a user will full permissions to that database, can be performed with the following
command. Note that to prevent the password from showing up in Bash history, start the command with a space!

```bash
 ./postgresql-add.sh thedatabasename thepassword
```

This script takes two arguments:

- The name of the database and the database user with full permissions to that database (always the same)
- The password for the new PostgresSQL database user

## PhantomJS

PhantomJS is a complete implementation of a headless WebKit web browser. It can be used to test web
sites automatically and create screen dumps of web site pages. This command and its pre-requisites can
be installed with the following command.

```bash
sudo ./phantomjs-setup.sh
```

It will do the follwing:

- Download source code for version 1.5 from googlecode.com and build it in /usr/local/phantomjs
- Install a link to the binary in /usr/local/bin to have it accessible from anywhere

## License

All scripts are released to the public domain and are free to use and modify for all.
