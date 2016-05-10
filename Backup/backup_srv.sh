#!/bin/bash
#
# Name: backup_srv.sh
#
# Description: Use cron to launch this script daily.
#              Creating archive of system directories (Keep 5 days) => Daily Dir arch
#              Dump all databases (Keep 15 days) => Daily dumps
#              On first day of month, Dump all databases to other directory (Keep 12 months) => Monthly dumps
#
# sysGwan _ 02052016
# admin@sysgwan.fr
#
################################################################################

## VARS
SRV=$(/bin/hostname -s)
MAIL=user@domain.com
LOG=/var/log/backup_srv_${SRV}.log
LCK=/tmp/backup_srv_${SRV}.lock
DATE=$(date +%d%m%Y_%HH%Mm)
DAY=$(date +%d)
BACKUPDIR=/mnt/backup
BACKUPDBDIR=/mnt/backup/databases
BACKUPSYSDIR=/mnt/backup/files
KEEPFILESDAYS=5
KEEPDBDAYS=15
KEEPDBMONTHS=12
MYSQL_USER="USER"
MYSQL=/usr/bin/mysql
MYSQL_PASSWORD="PASSWORD"
MYSQLDUMP=/usr/bin/mysqldump

declare -a DIR=(
/root
/home
/etc
/var
)

## FUNCTIONS
function MailNotif()
{
  echo "$*" | mail -s Script\ Error\ :\ $(basename "$0")\ on\ ${SRV} ${MAIL}
  echo "$*" >> ${LOG}
}

function ARCH()
{
  for REP in ${DIR[@]}
  do
    echo -e "${REP} will be compressed to ${BACKUPSYSDIR}!"
    saved_dir=$(echo ${REP} | sed -e 's#^/##' -e 's#/#_#')
    tar -czvf ${BACKUPSYSDIR}/bak_${saved_dir}_${DATE}.tar.gz ${REP}
  done

  if [ "${KEEPFILESDAYS}" != "0" ]; then
    if [[ ! -z ${KEEPFILESDAYS} ]]; then
      if [[ ${KEEPFILESDAYS} =~ ^[0-9]+$ ]]; then
        echo -e "Deleting archives older than ${KEEPFILESDAYS} days"
        find ${BACKUPSYSDIR}/*.tar.gz -mtime +${KEEPFILESDAYS} -exec rm {} \;
      else
        MailNotif "KEEPFILESDAYS MUST be numeric (defined as \"${KEEPFILESDAYS}\"), older arch files were not removed !"
        rm -f ${LCK}
      fi
    fi
  fi
}

function DAILYDUMP()
{
  DBs=$($MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)")
  for db in ${DBs}; do
    ${MYSQLDUMP} --force --opt --user=${MYSQL_USER} -p${MYSQL_PASSWORD} --databases ${db} > "${BACKUPDBDIR}/daily/bak_${db}_${DATE}.sql"
  done

  if [ "${KEEPDBDAYS}" != "0" ]; then
    if [[ ! -z ${KEEPDBDAYS} ]]; then
      if [[ ${KEEPDBDAYS} =~ ^[0-9]+$ ]]; then
        echo -e "Deleting databases older than ${KEEPDBDAYS} days"
        find ${BACKUPDBDIR}/daily/*.sql -mtime +${KEEPDBDAYS} -exec rm {} \;
      else
        MailNotif "KEEPDBDAYS MUST be numeric (defined as \"${KEEPDBDAYS}\"), older dbs sql files were not removed !"
        rm -f ${LCK}
      fi
    fi
  fi
}

function MONTHLYDUMP()
{
  DBs=$($MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)")
  for db in ${DBs}; do
    ${MYSQLDUMP} --force --opt --user=${MYSQL_USER} -p${MYSQL_PASSWORD} --databases ${db} > "${BACKUPDBDIR}/monthly/bak_${db}_${DATE}.sql"
  done

  if [ "${KEEPDBMONTHS}" != "0" ]; then
    if [[ ! -z ${KEEPDBMONTHS} ]]; then
      if [[ ${KEEPDBMONTHS} =~ ^[0-9]+$ ]]; then
        echo -e "Deleting databases older than ${KEEPDBMONTHS} months"
        find ${BACKUPDBDIR}/monthly/*.sql -mtime +${KEEPDBMONTHS} -exec rm {} \;
      else
        MailNotif "KEEPDBMONTHS MUST be numeric (defined as \"${KEEPDBMONTHS}\"), older dbs sql files were not removed !"
        rm -f ${LCK}
      fi
    fi
  fi
}

## EXEC
# Check backup directories
for BCKDIR in ${BACKUPDIR} ${BACKUPSYSDIR} ${BACKUPDBDIR}
do
  if [ ! -d ${BCKDIR} ]; then
    MailNotif "${BCKDIR} is unreachable or doesn't exists, exit ..."
    rm -f ${LCK}
    exit 1
  fi
done

# Create db dirs if they are missing
if [ ! -d ${BACKUPDBDIR}/daily ]; then
  mkdir ${BACKUPDBDIR}/daily
elif [ ! -d ${BACKUPDBDIR}/monthly ]; then
  mkdir ${BACKUPDBDIR}/monthly
fi

# Check MySQL connection with defined user
MYCONX=$(${MYSQL} --user=$MYSQL_USER -p$MYSQL_PASSWORD -e 'use mysql')
RETVAL=$?
if [[ ${RETVAL} -ne 0 ]]; then
  MailNotif "Unable to connect to MySQL with ${MYSQL_USER} user"
  rm -f ${LCK}
  exit 1
fi

# Executing backup
echo -e "#################################################################"
echo -e ".: $(date +%c) : Starting backup datas for ${SRV} to ${BACKUPDIR} :."
echo -e "#################################################################"

if [ ! -s ${LCK} ]; then
    echo "INFO: Create lock file ${LCK}"
    date > ${LCK}
else
    MailNotif "ERROR: lock file already exists, execution aborted ..."
    exit 1
fi

if [[ ${DAY} -eq 01 ]]; then
#  ARCH
  DAILYDUMP
  MONTHLYDUMP
else
#  ARCH
  DAILYDUMP
fi

echo -e "Deleting lock file ${LCK}"
rm -f ${LCK}

echo -e "###################################################################################"
echo -e ".: $(date +%c) : All datas have been successfully backup for ${SRV} to ${BACKUPDIR} :."
echo -e "###################################################################################"

exit 0

# EOS
