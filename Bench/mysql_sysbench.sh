#!/bin/bash
SOCKET="/var/lib/mysql/mysql.sock"
DATABASENAME="sbtest"
TABLESIZE=50000
MAXREQUESTS=0
THREADS=16
TIME=60
RW=
HOST=127.0.0.1
USER=root
PASSWORD=
TEST=/usr/share/doc/sysbench/tests/db/oltp.lua
SYSBENCH=/usr/bin/sysbench

usage(){
   echo -n "${0} [ -p (prepare) | -r (run) | -c (cleanup) | -h (help) read/write ]"
   echo
}

if [ ! -x ${SYSBENCH} ]; then
   echo "${SYSBENCH} is missing, install sysbench first. exit ... "
   exit 1
fi

if [[ ${1} == "-h" ]] || [[ ${1} == "--help" ]]; then
   usage
   exit 1
fi

if [[ ${2} == "read" ]]; then
   RW=on
elif [[ ${2} == "write" ]]; then
   RW=off
else
   echo "Mode must be specified: read or write, see -h"
   exit 1
fi

ARGUMENTS="--mysql-host=${HOST} --mysql-user=${USER} --mysql-password=${PASSWORD} --oltp-test-mode=complex --oltp-reconnect-mode=session --oltp-range-size=500 --oltp-point-selects=10 \
--oltp-simple-ranges=1 --oltp-sum-ranges=1 --oltp-order-ranges=1 --oltp-distinct-ranges=1 --oltp-index-updates=1 --oltp-non-index-updates=1 --oltp-nontrx-mode=select \
--oltp-connect-delay=10 --oltp-user-delay-min=0 --oltp-user-delay-max=0 --db-ps-mode=auto --debug=off --test=${TEST} --oltp-table-size=${TABLESIZE} --mysql-db=${DATABASENAME} \
--mysql-table-engine=InnoDB --max-time=${TIME} --num-threads=${THREADS} --max-requests=${MAXREQUESTS} --oltp-auto-inc=off --mysql-engine-trx=yes --db-driver=mysql --mysql-ignore-duplicates --oltp-read-only=${RW}"


if [[ ${1} == "-p" ]]; then
   mysql -u${USER} -h${HOST} -e "CREATE DATABASE IF NOT EXISTS sbtest;"
   ${SYSBENCH} ${ARGUMENTS} prepare
elif [[ ${1} == "-r" ]]; then
   ${SYSBENCH} ${ARGUMENTS} run
elif [[ ${1} == "-c" ]]; then
   ${SYSBENCH} ${ARGUMENTS} cleanup
elif [[ ${1} == "-h" ]]; then
   usage
   exit 1
else
   echo "Missing parameter or bad arg ! See -h."
   exit 1
fi

#EOS
