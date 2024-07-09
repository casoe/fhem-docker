#!/bin/bash
# db-dumpandrestore.sh
# Carsten Söhrens, 13.07.2023

DBFILE=db_backup_$(date -I).sqlc

echo "set dblog reopen 7200" |  /bin/nc -w5 localhost 7072
pg_dump -v -Fc --file=$DBFILE -h localhost -U fhem -d fhem
pg_restore -Fc -v --clean -h localhost -U fhem -d fhem $DBFILE
echo "set dblog reopen" |  /bin/nc -w5 localhost 7072

rm $DBFILE
