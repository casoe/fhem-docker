#!/bin/bash
# db-copyfromlive.sh
# Carsten Söhrens, 22.01.2023

DBFILE=~/backup/db_backup_$(date -I).sqlc

rm -f $DBFILE
pg_dump -v -Fc --file=$DBFILE postgresql://fhem:fhem@192.168.2.5:5432/fhem
pg_restore -Fc -v --clean -h localhost -U fhem -d fhem $DBFILE
