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
MAIL=user@domain.fr
LOG=/var/log/dump_${SRV}.log
LOCALDIR=/home/DUMPS
BACKUPDIR=/mnt/backup/DUMPS
LCK=/tmp/dump_${SRV}.lock
USER=user
PASSWORD="xxxxxxxxxxxx"

DBs=(
DB1
DB2
DB3
)

## FUNCTIONS
function MailNotif()
{
    echo "$*" | mail -s Script\ Error\ :\ $(basename "$0")\ on\ $(/bin/hostname) ${MAIL}
    echo "$*" >> ${LOG}
}

function DUMP()
{
    echo -e "Deleting old local sql files into ${LOCALDIR}"
    rm -f ${LOCALDIR}/*.sql > /dev/null 2>&1
    for BASE in ${DBs[@]}
    do
        echo -e "\033[32m${BASE} will be dumped to ${LOCALDIR}!\033[0m"
        mysqldump -u${USER} -p${PASSWORD} ${BASE} > ${LOCALDIR}/${BASE}_${SRV}.sql
    done
}

function ARCH()
{
    echo -e "\033[32mDelete old sql files into ${BACKUPDIR}\033[0m"
    rm -f ${BACKUPDIR}/*.sql > /dev/null 2>&1
    echo -e "\033[32mCopy sql files from ${LOCALDIR} to ${BACKUPDIR}\033[0m"
    cp -rp ${LOCALDIR}/*.sql ${BACKUPDIR}/
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
    ARCH
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
