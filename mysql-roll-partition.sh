#!/bin/bash 

#### This script rolls partitions for a date partiton
#### so you run it on a range partition and it figures out the interval of days between two date partitions
#### and then it removes the first date partition and adds a new data partition an interval after the last.
####
#### This script does NOT change your DB it outputs SQL that you can use to change the DB.


. ./settings.conf


if test $# -ne 1
then
   echo "Usage $0 TABLE_NAME"
   exit
fi

TABLE_NAME=$1


second_to_last_line=""
last_line=""
lineno=1
while read line
do
   if test $lineno -eq 1
   then
    first_line=( $line )
   fi

   second_to_last_line=( ${last_line[@]} )
   last_line=( $line )
   let lineno=$lineno+1
done < <(echo "SELECT PARTITION_NAME, PARTITION_DESCRIPTION FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME = '$TABLE_NAME' AND TABLE_SCHEMA = '$DW_MYSQL_DB' ORDER BY PARTITION_DESCRIPTION ASC " | mysql -u $DW_MYSQL_USER -p$DW_MYSQL_PASS -h $DW_MYSQL_HOST $DW_MYSQL_DB  | tail -n +3 )

echo " ALTER TABLE $TABLE_NAME DROP PARTITION " ${first_line[0]} ";"

let days_increment=${last_line[1]}-${second_to_last_line[1]}
let latest_partition_description=${last_line[1]}+$days_increment
partition_name=` date --date "0000-01-01 + $latest_partition_description days" +%Y%m%d `

echo " ALTER TABLE $TABLE_NAME ADD PARTITION (PARTITION p$partition_name VALUES LESS THAN ($latest_partition_description)); "
