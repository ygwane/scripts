#!/bin/bash
#
# Name: mydumper_DBs_[server].sh
#
# Mydumper Infos:
# - Backup
# mydumper -t 8 -u root -h localhost -B test -o /root/test_dump
# mysql -e 'drop database test;'
# mysql -e 'create database test;'
# - Restore
# myloader -t 8 -u root -h localhost -d /root/test_dump
###############################################################

## VARS
SRV=$(/bin/hostname)
MAIL=user@domain.com
LOG=/var/log/mydumper_${SRV}.log
BACKUPDIR=/mnt/nfs/dir
LCK=/tmp/mydumper_${SRV}.lock

DBs=(
dbname1
dbname2
dbname3
)

## FUNCTIONS
function MailNotif() {
    echo "$*" | mail -s Script\ Error\ :\ $(basename "$0")\ on\ $(/bin/hostname) ${MAIL}
    echo "$*" >> ${LOG}
}

function DUMP() {
    for BASE in ${DBs[@]}
        do
            echo -e "\033[32m${BASE} will be dumped to ${BACKUPDIR}!\033[0m"
                mydumper -t 8 -u root -h localhost -B ${BASE} -o ${BACKUPDIR}/${BASE}
        done
}

## EXEC
echo -e "######################################################################"
echo -e ".: $(date +%c) : Starting dump databases for ${SRV} to ${BACKUPDIR} :."
echo -e "######################################################################"

if [ ! -s ${LCK} ]
then
    echo "INFO: Create lock file ${LCK}"
    date > ${LCK}
else
    MailNotif "ERROR: lock file ${LCK} already exists, execution aborted ..."
    exit 1
fi

if [ -d ${BACKUPDIR} ]
then
    echo -e "$(date +%c) : ${BACKUPDIR} is reachable, lauching backup !"
    DUMP
    echo -e "Deleting lock file ${LCK}"
    rm -f ${LCK}
else
    MailNotif "$(date +%c) : ${BACKUPDIR} is unreachable, execution aborted ..."
    exit 1
fi

echo -e "##########################################################################################"
echo -e ".: $(date +%c) : All databases have been successfully dumped for ${SRV} to ${BACKUPDIR} :."
echo -e "##########################################################################################"

# EOS
