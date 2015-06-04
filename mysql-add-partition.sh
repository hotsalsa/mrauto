# this script sets up partitions. if there were already partitions. it reorganizes them.
# you can safely run this script multiple times to change partitions, but, it runs slowly and will lock up the tables


if test $# -ne 5
then
   echo "Usage $0 LATEST_DATE NUMBER_OF_DATA_PARTITIONS DAYS_IN_PARTITION DATE_FIELD_NAME TABLE_NAME" 
   exit
fi

# 

LATEST_DATE=` date --date "$1 +1 day" +%F `  # a date presumably 
NUMBER_OF_DATA_PARTITIONS=$2
DAYS_IN_PARTITION=$3
DATE_FIELD_NAME=$4  # event_date
TABLE_NAME=$5

echo "ALTER TABLE $TABLE_NAME PARTITION BY RANGE (TO_DAYS($DATE_FIELD_NAME))"
echo "("

echo "PARTITION perror VALUES LESS THAN (to_days('2000-01-01')) "
let x=$NUMBER_OF_DATA_PARTITIONS
while test $x -ge 0
do    
        let mdays=$x*$DAYS_IN_PARTITION
	let x=$x-1;
        END_DATE=` date --date="$LATEST_DATE - $mdays day" +%F `
        END_DATE_NAME=` date --date="$LATEST_DATE - $mdays day" +"%Y%m%d"`
        echo ", PARTITION p$END_DATE_NAME VALUES LESS THAN (TO_DAYS('$END_DATE')) "
done


echo ");"
