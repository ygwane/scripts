#!/bin/bash
#
# Name: dump_dbs_[server].sh
#
# Description: Dump databases from localhost to
#              NFS mount directory stored on NAS server
#
#######################################################

## VARS
SRV=$(/bin/hostname)
MAIL=user@domain.com
LOG=/var/log/dump_${SRV}.log
BACKUPDIR=/mnt/backup
LCK=/tmp/dump_${SRV}.lock

DBs=(

)

## FUNCTIONS
function MailNotif()
{
    echo "$*" | mail -s Script\ Error\ :\ $(basename "$0")\ on\ $(/bin/hostname) ${MAIL}
    echo "$*" >> ${LOG}
}

function DUMP()
{
    for BASE in ${DIR[@]}
    do
        echo -e "\033[32m${BASE} will be dumped to ${BACKUPDIR}!\033[0m"
        mysqldump -uroot ${BASE} > ${BACKUPDIR}/${BASE}_${SRV}.sql
    done
}

## EXEC
echo -e "####################################################################"
echo -e ".: $(date +%c) : Starting dump dbs for ${SRV} to ${BACKUPDIR} :."
echo -e "####################################################################"

if [ ! -s ${LCK} ]
then
    echo "INFO: Create lock file ${LCK}"
    date > ${LCK}
else
    MailNotif "ERROR: lock file already exists, execution aborted ..."
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

echo -e "############################################################################################"
echo -e ".: $(date +%c) : MySQL dumps have been successfully backup for ${SRV} to ${BACKUPDIR} :."
echo -e "############################################################################################"

# EOS
