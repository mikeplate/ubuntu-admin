#!/bin/bash
#
# Backup all sites and the configuration of nginx to /srv/www/backup directory

# UNDER DEVELOPMENT. JUST TESTING.

find . -type f -exec stat -c "%y" {} \; | sort -n | tail -1

