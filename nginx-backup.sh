#!/bin/bash
#
# Backup all sites and the configuration of nginx to /var/backups/nginx/

function do_backup {
    local DIR=$1
    local NAME=$2

    local LAST_MOD=$(find $DIR -type f -exec stat -c '%y' {} \; | sort -n | tail -1)
    local BACKUP_FILE=/var/backups/nginx/$NAME.tar.gz
    if [ -f $BACKUP_FILE ]; then
        local BACKUP_MOD=$(stat -c '%y' $BACKUP_FILE)
    else
        local BACKUP_MOD=''
    fi

    if [[ "$LAST_MOD" > "$BACKUP_MOD" ]]; then
        echo "Create new backup for $NAME"
        tar -c $DIR | gzip > $BACKUP_FILE
        chown root:root $BACKUP_FILE
        chmod 600 $BACKUP_FILE
    else
        echo "Skipping backup for $NAME"
    fi
}

# Ensure backup location exists
if [ ! -d /var/backups/nginx ]; then
    mkdir -p /var/backups/nginx
    chown root:root /var/backups/nginx
    chmod 700 /var/backups/nginx
fi

# Backup all nginx directories
for BASE_DIR in /srv/www/*; do
    if [ -d $BASE_DIR ]; then
        BASE_NAME=$(basename $BASE_DIR)
        if [ -d $BASE_DIR/public ]; then
            do_backup $BASE_DIR $BASE_NAME
        else
            for SUB_DIR in $BASE_DIR/*; do
                if [ -d $SUB_DIR ]; then
                    SUB_NAME=$(basename $SUB_DIR)
                    if [ ! "$SUB_NAME" == 'dev' ]; then
                        do_backup $SUB_DIR "$BASE_NAME-$SUB_NAME"
                    fi
                fi
            done
        fi
    fi
done

do_backup /etc/nginx nginx
do_backup /var/log/nginx nginx-log

echo "Create new backup for system users"
BACKUP_FILE=/var/backups/system-users.tar.gz
tar -c /etc/{passwd,group,shadow} | gzip > $BACKUP_FILE
chown root:root $BACKUP_FILE
chmod 600 $BACKUP_FILE

