# Ubuntu Administration Scripts

This repository contains a collection of Bash scripts for automating the administration of Ubuntu web 
servers. Note that all choices made are my own personal preferences and they might not be the best
or recommended way of setting up a web server.

All scripts are supposed to be run as root. This is checked at the beginning of every script.

## Install general components

On a fresh installation of an Ubuntu server, the following command can be used to install general
components:

```bash
./install
```

It will do the following:

- Update and upgrade all packages
- Configure clock syncing by scheduling ntpdate to run
- Install Nginx
- Install MariaDB for MySql compatability
- Install Certbot for creating certificates using Let's Encrypt

## Add a new php site

```bash
./add-php company companydomainname.com
```

It will do the following:

- Create directory for web site under /var/www
- Copy template files to web site
- Create Nginx configuration for site
- Set permissions on web site directory and files
- Create certificate for https access
- Add Nginx configuration for certificate

## Add a new WordPress site

```bash
./add-wordpress site wp.site.com
```

It will do the following:

- Add php site if it does not exist (including certificate for https)
- Add WordPress files if they don't exist
- Create MySql databas with user and passwords
- Configure WordPress for the created database

## Disable a site (keep all settings and files)


```bash
./disable-site company
```

## Enable a site (that has previously been disabled)

```bash
./enable-site company
```

## Delete a site permanently

Note that this command will delete all settings and files for the site. The script asks for
confirmation by typing 'yes' before actually deleting the site.

```bash
./delete-site company
```

## License

All scripts are released to the public domain and are free to use and modify for all.
