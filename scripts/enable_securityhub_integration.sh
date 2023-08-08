#!/bin/bash
# Copyright 2023 Chris Farris <chris@primeharbor.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#
# This script will enable a Security Hub Integration in EVERY account & region.
# You need to pass in a cross-account role with full permissions to Security Hub and the ProductArn for the integration to enable
#


ROLENAME=$1
ProductArn=$2

if [ -z $ProductArn ] ; then
  echo "usage $0 <ROLENAME> <ProductArn>"
  exit 1
fi

while read line ; do

  # extract the values we need
  ACCOUNT_ID=`echo $line | awk '{print $1}'`

  aws sts assume-role --role-arn arn:aws:iam::$ACCOUNT_ID:role/$ROLENAME --role-session-name Disable-Security-Hub-Standards --query Credentials > ${ACCOUNT_ID}_creds.json

  export AWS_SECRET_ACCESS_KEY=`cat ${ACCOUNT_ID}_creds.json | jq .SecretAccessKey -r`
  export AWS_ACCESS_KEY_ID=`cat ${ACCOUNT_ID}_creds.json | jq .AccessKeyId -r `
  export AWS_SESSION_TOKEN=`cat ${ACCOUNT_ID}_creds.json | jq .SessionToken -r `
  rm ${ACCOUNT_ID}_creds.json

  REGIONS=`aws ec2 describe-regions --query 'Regions[].[RegionName]' --output text`
  for r in $REGIONS ; do

    # Thanks ChatGPT for this funky awk
    product_arn=`echo "$ProductArn" | awk -v replacement="$r" -F':' '{if (NF >= 4) {$4 = replacement; } output = $1; for (i = 2; i <= NF; i++) {output = output ":" $i; } print output; }'`

    echo "Enabling $product_arn in ${ACCOUNT_ID} ${r}"
    aws securityhub enable-import-findings-for-product --product-arn $product_arn --region $r --output text
    if [[ $? -ne 0 ]] ; then
      exit 1
    fi

  done
  unset AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID AWS_SESSION_TOKEN

done < <(aws organizations list-accounts --query Accounts[].[Id,Status] --output text | grep ACTIVE )

