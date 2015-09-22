#!/bin/bash
#
# Name: backup_datas_[server].sh
#
# Description: Archive datas from localhost to
#              NFS mount directory stored on NAS server
#
#######################################################

## VARS
SRV=$(/bin/hostname)
MAIL=user@domain.com
LOG=/var/log/backup_${SRV}.log
BACKUPDIR=/mnt/backupdir/
LCK=/tmp/backup_${SRV}.lock

DIR=(
/dir1
/dir2
/dir3
/dir/dir4
)

## FUNCTIONS
function MailNotif()
{
    echo "$*" | mail -s Script\ Error\ :\ $(basename "$0")\ on\ $(/bin/hostname) ${MAIL}
    echo "$*" >> ${LOG}
}

function ARCH()
{
    for REP in ${DIR[@]}
    do
        echo -e "\033[32m${REP} will be compressed to ${BACKUPDIR}!\033[0m"
        tar -czvf ${BACKUPDIR}/${REP}_${SRV}.tar.gz ${REP}
    done
}

## EXEC
echo -e "####################################################################"
echo -e ".: $(date +%c) : Starting backup datas for ${SRV} to ${BACKUPDIR} :."
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
    ARCH
    echo -e "Deleting lock file ${LCK}"
    rm -f ${LCK}
else
    MailNotif "$(date +%c) : ${BACKUPDIR} is unreachable, execution aborted ..."
fi

echo -e "######################################################################################"
echo -e ".: $(date +%c) : All datas have been successfully backup for ${SRV} to ${BACKUPDIR} :."
echo -e "######################################################################################"

# EOS
