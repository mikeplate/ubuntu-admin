#!/bin/bash

read -p 'Remote address: ' remote_address
read -p 'Remote user name: ' remote_user

key_file_name="${remote_user}_dsa"
if [ -f "~/.ssh/$key_file_name" ]; then
    echo 'A key file already exists with the name ' $key_file_name
    exit 1
fi
ssh-keygen -t dsa -f "~/.ssh/$key_file_name" -N ''

echo 'You will be prompted for the remote user password twice'

# Make sure .ssh directory exists in remote user's home directory
ssh $remote_user@$remote_address 'if [ ! -d ~/.ssh ]; then mkdir ~/.ssh; chmod 0700 ~/.ssh; fi'

# Copy public key file to remote host
scp "~/.ssh/$key_file_name.pub" $remote_user@$remote_address:.ssh/authorized_keys2

