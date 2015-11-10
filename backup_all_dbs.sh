#!/bin/bash
#
#
USER="user"
PASSWORD="password"
DIR="/dir/to/arch/DBs"

# Purge old dumps 
rm "$DIR/*gz" > /dev/null 2>&1

# Define DBs list 
databases=$(mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

# Backup 
for db in $databases
do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]]
    then
        echo "Dumping database: $db"
        mysqldump --force --opt --user=$USER --password=$PASSWORD --databases $db > $DIR/$(date +%Y%m%d).$db.sql
        gzip $DIR/$(date +%Y%m%d).$db.sql
    fi
done

# EOS
