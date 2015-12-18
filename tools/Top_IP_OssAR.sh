#!/bin/bash
#
# Name: Top_IP_OssAR.sh
#
# Description: This script read the OSSEC active response log file:
#                               1- Extracting IP and sort them
#                               2- Make a top of most blocked IP address per day, writing on both stdout and log file
#                               3- Send report by mail
###########
# VAR
TOP=1
MAIL=user@mail.com
TILF=/tmp/topIP.log
REPORT=/tmp/resultIP.log
ARLF=/var/ossec/logs/active-responses.log
DAY=$(ls -l ${ARLF} | awk '{print $6}')
MONTH=$(ls -l ${ARLF} | awk '{print $7}')
YEAR=$(date +%Y)
DATE=$(echo "${DAY}_${MONTH}_${YEAR}")

# Read AR log file, extract IP, sort and write to log file
if [[ ! -s ${ARLF} ]]
then
        echo "${ARLF} log file is empty, exting ..."
        exit 1
fi

cat ${ARLF} | awk -F " " '{print $10}' | sort | uniq -c | sed 1d | sort -t " " -gr > ${TILF}

# Remove result log if exists
if [[ -f ${REPORT} ]]
then
        rm -f ${REPORT} touch ${REPORT}
fi

# Parse log file to make top with pos IP Country and blocked number. Output: stdout & log file
for IP in $(cat ${TILF} | awk -F " " '{print $2}')
do
        COUNTRY=$(geoiplookup ${IP} | cut -d "," -f2)
        NB=$(cat ${TILF} | grep ${IP} | awk -F " " '{print $1}')
        echo "Top ${TOP} => IP: ${IP} from ${COUNTRY} was blocked ${NB} times" | tee -a ${REPORT}
        TOP=$((TOP+1))
done

# SEND REPORT by MAIL
if [[ ! -e ${REPORT} ]]
then
        echo "${REPORT} log file doesn't exists, exiting ... "
        echo "It's generally because ${ARLF} is empty !"
        exit 1
else
        cat ${REPORT} | mail -s Daily\ Top\ Blocked\ IP\ by\ OSSEC\ on\ $(/bin/hostname)\ for\ ${DATE} ${MAIL}
fi

# EOS
