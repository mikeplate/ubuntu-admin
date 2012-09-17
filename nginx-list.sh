#!/bin/bash
#
# List all web sites on the server

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script is designed to run as root'
    exit
fi

# Gather paths for all sites
declare -a sites
for site_dir in /srv/www/*
do
    if [ -d "$site_dir" ]; then
        site_user=$(echo $site_dir | awk -F'/' '{print $NF}')
        id $site_user >/dev/null 2>/dev/null
        if [ $? -eq 0 ]; then
            for site_subdir in $site_dir/*
            do
                if [ -d "$site_subdir" ]; then
                    dir_name=$(echo $site_subdir | awk -F'/' '{print $NF}')
                    if [ "$dir_name" != 'dev' ]; then
                        sites+=($site_subdir)
                    fi
                fi
            done
        else
            sites+=($site_dir)
        fi
    fi
done

# Print all site names (last directory name in path)
for site in "${sites[@]}"
do
    echo "${site##*/}"
done

# Process all site configuration files
for site_file in /etc/nginx/sites/*
do
    site_hostnames=$(grep 'server_name' $site_file)
    [[ $site_hostnames =~ server_name\ (.+)\; ]]
    site_hostnames=${BASH_REMATCH[1]}

    site_root=$(grep 'root' $site_file)
    [[ $site_root =~ root\ (.+)\; ]]
    site_root=${BASH_REMATCH[1]}

    # echo $site_hostnames'|'$site_root
done

