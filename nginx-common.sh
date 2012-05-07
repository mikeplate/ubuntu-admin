#!/bin/bash
#
# Common functions for nginx administration, shared by Ruby, Php and possibly more scripts

function prepare_user {
    local user_name=$1

    # Does user exist?
    HOMEDIR=/srv/www/$user_name
    id $user_name > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        # Add new user
        mkdir -p $HOMEDIR
        useradd --home "$HOMEDIR" $user_name
        chown root:$user_name $HOMEDIR
        chmod 0751 $HOMEDIR

        # Set up for logging
        mkdir $HOMEDIR/dev
        chown root:root $HOMEDIR/dev
        chmod 0751 $HOMEDIR/dev
    fi

    # Does sftp group exist?
    cat /etc/group | grep sftp > /dev/null
    if [ $? -ne 0 ]; then
        addgroup sftp > /dev/null
        grep 'Match Group sftp' /etc/ssh/sshd_config
        if [ $? -ne 0 ]; then
            echo 'Match Group sftp' >> /etc/ssh/sshd_config
            echo '    ChrootDirectory %h' >> /etc/ssh/sshd_config
            echo '    ForceCommand internal-sftp' >> /etc/ssh/sshd_config
            echo '    AllowTcpForwarding no' >> /etc/ssh/sshd_config
        fi
    fi
    usermod -a -G sftp $user_name

    # Set up for logging sftp operations for this user
    if [ ! -f /etc/rsyslog.d/sftp.conf ]; then
        echo ':programname, isequal, "internal-sftp" /var/log/sftp.log' >> /etc/rsyslog.d/sftp.conf
        echo ':programname, isequal, "internal-sftp" ~' >> /etc/rsyslog.d/sftp.conf
    fi
    sed -i "/sftp.log/i \$AddUnixListenSocket $HOMEDIR/dev/log" /etc/rsyslog.d/sftp.conf
    restart rsyslog
}



