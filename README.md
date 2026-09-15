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

## Install nginx, .NET and Certbot for dotnet sites

`add-dotnet` runs this automatically, so you normally don't need to call it directly.
It is safe to run repeatedly - each step only runs if it hasn't already been done.

```bash
./install-web
```

It will do the following:

- Install and enable Nginx
- Install the latest ASP.NET Core runtime available from Ubuntu's own package repository
- Install Certbot via snap (the currently recommended way to install Certbot) for Let's Encrypt
  certificates, and configure automatic nginx reload on renewal
- Configure the firewall (ufw) to allow SSH, HTTP and HTTPS
- Add recommended baseline nginx configuration (max body size, security headers,
  WebSocket connection upgrade support)

## Add a new ASP.NET Core (dotnet) site

```bash
./add-dotnet company companydomainname.com
```

It will do the following:

- Run `install-web` to make sure nginx, .NET and Certbot are installed and configured
- Create a dedicated, unprivileged system user for the site (e.g. `site-company`) so that
  sites on the same server cannot access each other's files or processes
- Create `/var/www/company/app` for you to deploy your published application into (via
  `dotnet publish` + rsync/scp) and `/var/log/dotnet-sites/company` for application logs,
  both owned exclusively by the site's dedicated user
- Automatically pick a free local port for Kestrel to listen on (loopback only)
- Create an Nginx reverse proxy configuration for the site
- Create a systemd service (`kestrel-company`) to run the site as its dedicated user, with
  systemd sandboxing applied (no new privileges, private /tmp, read-only system paths, etc.)
- Create a certificate for https access and add the Nginx configuration for it

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
