#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
echo "Working dir is $DIR"

WORKING=$DIR
WORKDATE=`date "+%m%d%Y"`
WORKSEC=`date "+%s"`

RT53DIR=route53
ERP_DOMAIN=${DOMAIN}
ERP_FQDN=${1}.${ERP_DOMAIN}
ERP_RT53_ZONE_ID=${RT53_ZONE_ID}
instance=${2}

AWS_EC2_REGION=us-east-1
AWS_HOSTNAME=`aws ec2 describe-instances --region $AWS_EC2_REGION --instance-ids $instance | jq ' .Reservations[0] | .Instances[0] | .PublicDnsName' | sed 's/\"//g'`


makedns()
{
echo "In $FUNCNAME"
true
 
  ERP_CREATE=${RT53DIR}/create_${ERP_FQDN}_${WORKDATE}_rt53.json
  ERP_DELETE=${RT53DIR}/delete_${ERP_FQDN}_${WORKDATE}_rt53.json
  
cat << EOF > ${ERP_CREATE}
{ "Comment":"Create record for $XTCRMACCT on Route 53",  "Changes": [ {"Action": "CREATE", "ResourceRecordSet":  {  "Name": "${ERP_FQDN}.", "Type": "CNAME", "TTL": 60, "ResourceRecords":  [ {"Value": "${AWS_HOSTNAME}" } ] }  }  ] }
EOF

cat << EOF > ${ERP_DELETE}
{ "Comment":"Delete record for $XTCRMACCT on Route 53",  "Changes": [ {"Action": "DELETE", "ResourceRecordSet":  {  "Name": "${ERP_FQDN}.", "Type": "CNAME", "TTL": 60, "ResourceRecords":  [ {"Value": "${AWS_HOSTNAME}" } ] }  }  ] }
EOF
}

# Add the new DNS entry to Route53
dodns()
{
echo "In $FUNCNAME"
true

   ERPCMD="aws route53 change-resource-record-sets --hosted-zone-id ${ERP_RT53_ZONE_ID} --change-batch file://${ERP_CREATE}"
   RT53ADDERP=`${ERPCMD}`
## TODO: Add pass/fail

cat << EOF > ${RT53DIR}/${XTCRMACCT}_${WORKDATE}_${EC_FQDN}_delete_domain.sh
aws route53 change-resource-record-sets --hosted-zone-id ${ERP_RT53_ZONE_ID} --change-batch file://"${ERP_DELETE}"
EOF


}

makedns
dodns
