#!/bin/bash
#
# Preconf CentOS 7 installed from scratch
#
##############

# Get ifconfig
echo
echo "Get ifconfig"
echo
yum install -y net-tools

# Set hostname
echo
echo "Enter hostname to set on this machine:"
read HOSTNAME
echo "Define hostname"
hostnamectl set-hostname ${HOSTNAME}

# Disable firewalld
echo
echo "Disable firewalld"
echo
systemctl mask firewalld
systemctl stop firewalld

# Install repos
echo
echo "Installing repos"
echo
rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install basics
echo
echo "Installing basics"
echo
yum install -y htop iotop nload nmap ntp unzip telnet traceroute nc bind-utils rsync mlocate screen ncdu inxi

# Enable NTP
echo
echo "Start NTPD"
echo
systemctl enable ntpd
service ntpd restart

# Create bases directories
echo
echo "Create /downloads and /scripts directories"
echo
