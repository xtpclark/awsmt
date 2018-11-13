#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
echo "Working dir is $DIR"
DATE=`date`
AWS_VOL=$1

for VOL in $AWS_VOL; do
aws ec2 delete-volume --volume-id $VOL
echo "$VOL deleted on $DATE" >> VolDelete.log
done


exit 0;
