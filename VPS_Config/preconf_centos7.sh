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

# Install iptables service
echo
echo "Install iptables service, enabled"
echo
yum install -y iptables-service
systemctl enable iptables 
service iptables start

# Install repos
echo
echo "Installing repos"
echo
rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install basics
echo
echo "Installing basics"
echo
yum install -y htop iotop nload nmap chrony unzip telnet traceroute nc bind-utils rsync mlocate screen ncdu inxi

# Enable Chronyd
echo
echo "Start Chrony"
echo
systemctl enable chronyd
service chronyd restart

# Create bases directories
echo
echo "Create /downloads and /scripts directories"
echo
mkdir /downloads && mkdir /root/scripts

# Generate SSH key
echo
echo "Generate SSH Key"
echo
ssh-keygen

# Reboot
echo
echo "Press enter to reboot now (ctrl + C to exit)"
read
reboot
