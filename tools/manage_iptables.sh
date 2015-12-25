#!/bin/bash
#
# Script name: manage_iptables.sh
#
# Description: Script used to manage iptables rules
# 1- you can add a rule to open port locally or to create a NAT rule into FORWARD table
# 2- you can delete a rule to close port locally or to delete a NAT rule into FORWARD table
# 3- you can also list loaded rules w/ numeric port display
# 4- you can drop IP address to avoid brute force
#
# Note: this script edit the iptables rules files and reload iptables with his config file,
# we will not add or remove rules dynamically. (e.g: iptables -I INPUT ...)
#
###########################################################################################
## VAR
IPTABRULES=/etc/sysconfig/iptables
IFWAN=eno16780032
IFLAN=eno33559296

#set -x
## FUNCTION

#Write USAGE function
function usage()
{
  echo -e "\e[31m$0 require 2 args for editing rules !\e[0m"
  echo -e "\e[31m$0 require only one arg for listing rules or dropping bastards !\e[0m"
  echo
  echo -e "\tFirst arg must be one of the following:"
  echo -e "\t[add | del OR list | drop (2nd arg not required)]"
  echo
  echo -e "\tSecond arg must be one of the following:"
  echo -e "\t[local / nat]"
  echo
  echo -e "\e[32mUsage example: $0 add local | $0 del nat | $0 list\e[0m"
  echo
  echo -e "To see help: -h, --help, help"
  echo
}
function listing()
{
  echo -e "\e[31mListing iptables loaded rules :\e[0m"
  echo
  iptables -L -n
}

function trynumv()
{
  [[ ${portNb} =~ ^[0-9]+$ ]] || { echo -e "\e[33mNot a numeric value, try again\e[0m"; exit 1; }
}

function checkportipt()
{
    if grep -q ${portNb} ${IPTABRULES}; then
      echo -e "\e[33m${portNb} already present in ${IPTABRULES}, exit ...\e[0m" && exit 1
    fi
}

function checknoportipt()
{
    if grep -q ${portNb} ${IPTABRULES}; then
      echo "Closing ${portNb}"
    else
      echo -e "\e[33m${portNb} not present in ${IPTABRULES}, exit ...\e[0m" && exit 1
    fi
}

function iptsave()
{
  iptables-save > ${IPTABRULES}.sav
}

function iptload()
{
  iptables-restore < ${IPTABRULES}
  rm -f ${IPTABRULES}_PROD && cp ${IPTABRULES} ${IPTABRULES}_PROD
}

function drop()
{
  echo -e "\e[31mEnter IP address top drop permanently:\e[0m"
  read IPDrop
  if [[ ${IPDrop} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    iptables -I INPUT -j DROP -s ${IPDrop}
    echo -e "\e[32mIP ${IPDrop} was dropped !\e[0m"
    listing | grep ${IPDrop}
  else
    echo -e "\e[31mIP : ${IPDrop} is not valid address, try again.\e[0m"
    exit 1
  fi
}

## TEST specified args
if [[ ${#} -gt 2 ]]; then
  echo "Control args number" && usage && exit 1
elif [[ ${1} == -h ]] || [[ ${1} == help ]] || [[ ${1} == --help ]]; then
  echo "Displaying help" && usage && exit 1
elif [[ ${1} == add ]] && [[ ${2} == local ]]; then
  VAR=addlocal
elif [[ ${1} == add ]] && [[ ${2} == nat ]]; then
  VAR=addnat
elif [[ ${1} == del ]] && [[ ${2} == local ]]; then
  VAR=dellocal
elif [[ ${1} == del ]] && [[ ${2} == nat ]]; then
  VAR=delnat
elif [[ ${1} == list ]]; then
  listing && exit 0
elif [[ ${1} == drop ]]; then
  drop && exit 0
else
  echo "Control args" && usage && exit 1
fi

## CASE for valid args (2)
case "${VAR}" in

  addlocal)
    echo -e "\e[31mEnter port number to open locally\e[0m"
    read portNb && trynumv
    echo -e "\e[92mPort to open locally is: ${portNb}, enter to confirm\e[0m"
    read
    checkportipt
    iptsave
    sed -i -e "/##LOCAL##/a -A INPUT -p tcp -m state --state NEW -m tcp --dport ${portNb} -j ACCEPT" ${IPTABRULES}
    iptload
    echo -e "\e[31mDone, old rules: iptables.sav, port ${portNb} is now open locally\e[0m"
    listing | grep -w "${portNb}"
    ;;

  addnat)
    echo -e "\e[31mEnter src port number to NAT (WAN)\e[0m"
    read portwNb && [[ ${portwNb} =~ ^[0-9]+$ ]] || { echo -e "\e[33mNot a numeric value, try again\e[0m"; exit 1; }
    echo -e "\e[92mSource port to NAT is: ${portwNb}\e[0m"
    echo
    if grep -q ${portwNb} ${IPTABRULES}; then
      echo -e "\e[33m${portwNb} already present in ${IPTABRULES}, exit ...\e[0m" && exit 1
    fi

    echo -e "\e[31mEnter dst port number to NAT (LAN)\e[0m"
    read portlNb && [[ ${portlNb} =~ ^[0-9]+$ ]] || { echo -e "\e[33mNot a numeric value, try again\e[0m"; exit 1; }
    echo -e "\e[92mDestination port to NAT is: ${portlNb}\e[0m"
    echo
    if $(grep -w ${portlNb} ${IPTABRULES} | grep FORWARD); then
      echo -e "\e[33m${portlNb} already present in ${IPTABRULES}, exit ...\e[0m" && exit 1
    fi

    echo -e "\e[31mEnter remote LAN IP to NAT\e[0m"
    read IPtoNAT
    if [[ ${IPtoNAT} =~ ^[192]+\.[168]+\.[9]+\.[0-9]+$ ]]
    then
      echo -e "\e[92mEdit iptables rules to add NAT rules w/ LAN IP: ${IPtoNAT}, Src WAN port: ${portwNb} and Dst LAN port: ${portlNb}, enter to confirm\e[0m"
      read
      iptsave
      sed -i -e "/##NAT1##/a -A PREROUTING -i ${IFWAN} -p tcp -m tcp --dport ${portwNb} -j DNAT --to-destination ${IPtoNAT}:${portlNb}" ${IPTABRULES}
      sed -i -e "/##NAT2##/a -A FORWARD -i ${IFWAN} -o ${IFLAN} -p tcp -m tcp --dport ${portlNb} -j ACCEPT" ${IPTABRULES}
      iptload
      echo -e "\e[31mDone, old rules: iptables.sav, WAN src port ${portwNb} is FORWARDed to LAN IP ${IPtoNAT} dst port ${portlNb}\e[0m"
      listing | grep "${portwNb}" | grep PREROUTING
      listing | grep "${portlNb}" | grep FORWARD
    else
      echo -e "\e[31mBad IP, must be: 192.168.9.0/24, exit\e[0m"
      exit 1
    fi
    ;;

  dellocal)
    echo -e "\e[31mEnter port number to close locally\e[0m"
    read portNb && trynumv
    echo -e "\e[92mPort to close locally is: ${portNb}, enter to confirm\e[0m"
    read
    checknoportipt
    iptsave
    sed -i "/--dport ${portNb}/d" ${IPTABRULES}
    iptload
    echo -e "\e[31mDone, old rules: iptables.sav, port ${portNb} is now closed locally\e[0m"
    listing | grep -w "${portNb}"
    ;;

  delnat)
    echo -e "\e[31mEnter port number to close in FORWARD table\e[0m"
    read portNb && trynumv
    echo -e "\e[92mPort to close in FORWARD table is: ${portNb}, enter to confirm\e[0m"
    read
    checknoportipt
    iptsave
    PREPORT=$(grep ${portNb} ${IPTABRULES} | grep PREROUTING)
    sed -i "/${PREPORT}/d" ${IPTABRULES}
    sed -i "/-A FORWARD -i ${IFWAN} -o ${IFLAN} -p tcp -m tcp --dport ${portNb}/d" ${IPTABRULES}
    iptload
    echo -e "\e[31mDone, old rules: iptables.sav, port ${portNb} is now closed (NAT closed)\e[0m"
    ;;

  *)
    echo -e "\e[31mbad arg, exit\e[0m"
    exit 1
    ;;

esac

# EOS
