#!/bin/bash

POLICY=lifecycle.json

BUCKETS=`aws s3 ls | grep bak_ | cut -d ' ' -f 3`
for BUCKET in $BUCKETS;
do
aws s3api put-bucket-lifecycle --bucket ${BUCKET} --lifecycle-configuration file://${POLICY}
RET=$?
echo "Returned ${RET} for ${BUCKET}"
done;
