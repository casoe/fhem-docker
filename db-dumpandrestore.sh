#!/bin/bash
# db-dumpandrestore.sh
# Carsten Söhrens, 13.07.2023

DBFILE=db_backup_$(date -I).sqlc

echo "Type in the FHEM command prompt: set dblog reopen 7200"
read -p "Press any key..."
echo "Dump started."
pg_dump -v -Fc --file=$DBFILE -h localhost -U fhem -d fhem
echo "Restore started."
pg_restore -Fc -v --clean -h localhost -U fhem -d fhem $DBFILE
echo "Type in the FHEM command prompt: set dblog reopen"

