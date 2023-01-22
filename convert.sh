#!/bin/bash

FILE=$1


while IFS=, read -r TIMESTAMP MAIN VALUE REST; do

  ADJUSTED=$(date -d "$TIMESTAMP -0 hour +43 minutes" +'%Y-%m-%d %H:%M:%S')

  if [ -z "$START" ] ; then
    START=$ADJUSTED
  else
    START=$(date -d "5 minutes $START" +'%Y-%m-%d %H:%M:%S')
  fi

  ##echo $START, $TIMESTAMP, $ADJUSTED

  SQL="insert into history (timestamp,device,type,event,reading,value) values ('$ADJUSTED','MQTT2_gasmeter','MQTT2_DEVICE','inserted','value','$VALUE');"
  echo $SQL

done < $FILE
