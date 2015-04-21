#!/bin/bash
#
# Script Name: PurgeRam.sh - GG - 2012
#
#######################################
### Script for purging of ram cache ###
#######################################

echo "free -m output command before purge"
free -m
echo "sync : Writing disk cache in progress"
sync
echo "OK"
echo "Purging RAM cache level 3"
echo "3" > /proc/sys/vm/drop_caches
echo "Waiting ..."
sleep 5
echo "sync : Writing disk cache 2 in progress"
sync
echo "Setting up RAM cache to default"
echo "0" > /proc/sys/vm/drop_caches
echo "RAM cache purge OK"
echo "Restart mysqld for create new cache"
service mysqld restart
echo "Restart httpd for create new cache"
service httpd --full-restart
echo "free -m output command after purge"
free -m
echo "******* End of operation ********"
# EOS
