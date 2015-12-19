#!/bin/bash
#
# Preconfig new centos 6 SRV x86_64 based
#
# GG _ 170515
##########################################

## ensure that network is correctly defined
echo -n "First, ensure that network is up, otherwise this script can't be correctly executed. To continue press [Enter], or to exit now: [CTRL + C] "
read

## asking hostname & confirm it
echo -n "Enter hostname to use for this new server: "
read SRVNAME

echo -n "hostname will be: ${SRVNAME}, confirm (Y/N) "
read CONF
case ${CONF} in
  Y)
    echo "hostname is ${SRVNAME}, we will define it now"
    ;;
  N)
    echo "bad hostname: ${SRVNAME}, you have to re-launch this script with good hostname"
	exit 0
	;;
  *)
    echo "Syntax error, enter Y or N, exiting ..."
	exit 1
	;;
esac

## config hostname
hostname ${SRVNAME}
sed -i -e "s/localhost.localdomain/\\${SRVNAME}/g" /etc/sysconfig/network
source /etc/sysconfig/network

## disable selinux
echo
echo "Disabling SELinux now"
echo
/usr/sbin/setenforce 0
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i -e 's/SELINUXTYPE=targeted/SELINUXTYPE=disabled/g' /etc/sysconfig/selinux
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i -e 's/SELINUXTYPE=targeted/SELINUXTYPE=disabled/g' /etc/selinux/config

## disable iptables
echo
echo "Disabling IPtables now"
echo
chkconfig iptables off && service iptables stop

## add repos & first yum exec
echo
echo "Install EPEL & RPMForge"
echo
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
echo
echo "Yum update & install Basics RPMs"
echo
yum update -y
yum install -y htop iotop nload ntp vsftpd wget unzip curl telnet traceroute nc bind-utils rsync mlocate vim-enhanced screen openssh

## config ntp
echo
echo "Config NTP"
echo
chkconfig ntpd on
service ntpd stop
service ntpd start

## create bases directories
echo
echo "Create /downloads and /scripts directories"
echo
mkdir /root/scripts
mkdir /downloads

## SSH keygen
echo
echo "Generate local SSH Keys"
echo
ssh-keygen

##
echo
echo -n "Preconf of this server is finished, Now you have to REBOOT !"
echo

# EOS
