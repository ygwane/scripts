#!/bin/bash
# LAMP INSTALL
#
# Update system
apt-get update && apt-get -y upgrade

# Install basics
apt-get install -y wget htop iotop nload unzip curl telnet traceroute rsync mlocate gzip ncdu vim mailutils
apt-get install -y ntp
systemctl enable ntp
service ntp start

# Install Apache, Config MPM Prefork
apt-get install -y apache2
a2dismod mpm_event
a2enmod mpm_prefork
a2enmod rewrite
a2enmod deflate
a2enmod ssl
a2ensite default-ssl
mv /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf_bak
wget http://62.210.13.170/setup/mpm_prefork.conf -O /etc/apache2/mods-available/mpm_prefork.conf
systemctl enable apache2
service apache2 restart

# Install MySQL, you must exec mysql_secure_installation.
apt-get install -y mysql-server
systemctl enable mysql

# Install PHP 5
apt-get install -y php5 php-pear
mkdir /var/log/php
chown www-data /var/log/php
apt-get install -y php5-mysql php5-apcu
apt-get install -y php5-cgi php5-cli php5-common php5-curl php5-dev php5-gd php5-idn php5-imagick php5-imap php5-mcrypt php5-memcache php5-mhash php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl
php5enmod mcrypt
# Install Memcached
apt-get install -y memcached
systemctl enable memcached
service memcached restart
service apache2 restart
# Tune PHP
mkdir /var/log/php
chown www-data:www-data /var/log/php && chmod 777 /var/log
sed -i -e 's/upload_max_filesize = 2M/upload_max_filesize = 32M/g' /etc/php5/apache2/php.ini
sed -i -e 's#;date.timezone =#date.timezone = Europe/Paris#g' /etc/php5/apache2/php.ini
sed -i -e 's#;error_log = syslog#error_log = /var/log/php/error.log#g' /etc/php5/apache2/php.ini
service apache2 restart

# Secure MySQL Install
service mysql restart
mysql_secure_installation

# EOS
