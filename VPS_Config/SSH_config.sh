#!/bin/bash
echo "Enter user name to create for SSH login"
read USER
adduser ${USER}
sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "AllowUsers ${USER}" >> /etc/ssh/sshd_config
service ssh restart
# EOS
