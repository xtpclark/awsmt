#!/bin/bash

CRMACCT=$1
DAYS=$2

getparams(){

if [[ "$DAYS" = "" ]]; then
ALL=true
fi

DATE=`date -d"${DAYS} day" "+%m%d%Y"`

if [[ "$CRMACCT" = "" ]]; then
echo "NEED TO SELECT AN ACCOUNT, EXITING!"
exit 1
fi

BUCKETPREFIX=bak
BUCKETNAME=${BUCKETPREFIX}_${CRMACCT}


}

listobj(){
# OBJLIST=`s3cmd ls s3://bak_${CRMACCT} | grep ${WORKDATE}`
OBJLIST=`s3cmd ls s3://${BUCKETNAME} | tr -s " " > list.tmp`

if [[ ${ALL} ]]; then
 echo "Listing all objects bucket"
   OBJSORT+=`cat list.tmp | cut -d' ' -f4  | grep -e ${CRMACCT} > list2.tmp`

 else
 echo "Listing objects from ${DATE}"

   OBJSORT+=`cat list.tmp | cut -d' ' -f4  | grep -e ${DATE} | grep -e ${CRMACCT} > list2.tmp`

fi

echo "Quit" >> list2.tmp
LIST=`cat list2.tmp`
rm list.tmp
}

downloadobj(){
PS3="Select number to download (q=exit):"
QUIT="Quit"
touch "$QUIT"

select FILENAME in ${LIST}; do
  case $FILENAME in
	"$QUIT")
	echo "Exiting."
	break
	;;
      *)
   echo "You selected ${FILENAME} ($REPLY)"

	if [[ ! -d downloads_${CRMACCT} ]]; then
	mkdir -p downloads_${CRMACCT}
	fi

  if [[ "${FILENAME}" = "" ]]; then
    echo "Quitting"

   else

   echo "Downloading ${FILENAME%%}"

   s3cmd get ${FILENAME} downloads_${CRMACCT}/ --quiet --force

   echo "Got it... in downloads_${CRMACCT}"

 fi

   break
       ;;
  esac
done

rm "$QUIT"

}

cleanup(){
echo "Cleaning Up"
rm list2.tmp
}

getparams

listobj

downloadobj

cleanup

exit
