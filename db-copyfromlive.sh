#!/bin/bash
# db-copyfromlive.sh
# Carsten Söhrens, 22.01.2023

mkdir -p ~/backup

DBFILE=~/backup/db_backup_$(date -I).sqlc

if [ ! -f "$DBFILE" ]; then
    echo "$DBFILE doesn't exist."
    echo "Dump is created."
    pg_dump -v -Fc --file=$DBFILE postgresql://fhem:fhem@192.168.2.5:5432/fhem
else
    echo "$DBFILE found."
fi

echo "Restore started."
pg_restore -Fc -v --clean -h localhost -U fhem -d fhem $DBFILE
