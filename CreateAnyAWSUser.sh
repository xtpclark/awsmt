#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
echo "Working dir is $DIR"

AWS_CREDENTIALS=${1}_cred.txt
USER=${1}
BUCKET=${USER}
GROUP=${2}

aws iam create-user --user-name ${1}
aws iam create-access-key --user-name ${1} > ${AWS_CREDENTIALS}

aws iam add-user-to-group --user-name ${1} --group-name ${GROUP}

# aws s3 mb s3://${BUCKET}
# aws s3 cp ${AWS_CREDENTIALS} s3://${BUCKET}/${AWS_CREDENTIALS}

AWS_ACCESSKEY=$(jq ".[] | .AccessKeyId" ${AWS_CREDENTIALS})
AWS_SECRET=$(jq ".[] | .SecretAccessKey" ${AWS_CREDENTIALS})

echo $AWS_ACCESSKEY
echo $AWS_SECRET

exit 0;
