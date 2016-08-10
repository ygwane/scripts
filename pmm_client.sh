#!/bin/bash
#
# Script name: pmm_client.sh
# Description: Bash script to install or remove pmm-client on LAN
#
#################################################################

# VARS
SRVADDR=192.168.0.130
SRVPORT=8888
IPADDR=$(ifconfig | grep "192.168" | awk '{print $2}')
PMMCLIENTDIR=/downloads/pmm-client
PMMCLIENTTAR=/downloads/pmm-client.tar.gz
RETVAL=

# FUNCTIONS
function install()
{

# Check if port 9000 is used
nc -zv 127.0.0.1 9000 1> /dev/null 2>&1
RETVAL=${?}
if [ ${RETVAL} -eq 0 ]
then
  echo "Port 9000 is actually in use on this host, we can't install PMM Client on it !"
  nc -zv 127.0.0.1 9000
  exit 1
else
  echo "Port 9000 is free, PMM Client will be installed !"
fi

# Install client
if [ ! -d ${PMMCLIENTDIR} ]
then
  mkdir -p ${PMMCLIENTDIR} && wget https://www.percona.com/redir/downloads/TESTING/pmm/pmm-client.tar.gz -P /downloads/
  tar xfz ${PMMCLIENTTAR} -C ${PMMCLIENTDIR} --strip-components=1 && rm -rf ${PMMCLIENTTAR}
  cd ${PMMCLIENTDIR} && ./install ${SRVADDR}:${SRVPORT} ${IPADDR}
  RETVAL=${?}
  if [ ${RETVAL} -ne 0 ]
  then
    echo "PMM Client install failed, exit !"
    exit 1
  fi
else
  echo
  echo -e "\t${PMMCLIENTDIR} directory already exists, pmm-client were not uninstalled yet;"
  echo -e "\tTry: [$0 remove] first, or remove ${PMMCLIENTDIR} directory manually"
  echo
  exit 1
fi

# Enable Metrics for OS and MySQL
which pmm-admin 1> /dev/null 2>&1
RETVAL=${?}
if [ ${RETVAL} -eq 0 ]
then
  pmm-admin add os ${IPADDR}
  pmm-admin add mysql
  pmm-admin list
  pmm-admin check-network
else
  echo "Command pmm-admin not found, can't install metrics"
fi

# Msg
echo "Now you can check graph on PMM server: http://${SRVADDR}:8888/"

}

function remove()
{

# Uninstall
if [ -d ${PMMCLIENTDIR} ]
then
  cd ${PMMCLIENTDIR} && ./uninstall
  rm -rf ${PMMCLIENTDIR}
else
  echo
  echo -e "\t${PMMCLIENTDIR} directory does not exists, uninstalling is not possible !"
  echo -e "\tOr pmm-client was already uninstalled, exiting ..."
  echo
  exit 1
fi

}

# Case
case "$1" in
  install)
    install
    ;;
  remove)
    remove
    ;;
  reinstall)
    remove
    install
    ;;
  *)
    echo "Usage: $0 (install|remove|reinstall)"
        exit 1
esac

# EOS
