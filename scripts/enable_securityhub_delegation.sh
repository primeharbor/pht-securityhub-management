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

# Script to enable Delegated Admin in a payer account for all Regions

SECURITY_ACCOUNT=$1

if [ -z $SECURITY_ACCOUNT ] ; then
	echo "Usage: $0 <security_account_id>"
	exit 1
fi

REGIONS=`aws ec2 describe-regions --query 'Regions[].[RegionName]' --output text`
for r in $REGIONS ; do
  echo "Enabling SecurityHub Delegated Admin in $r"
  aws securityhub enable-organization-admin-account --admin-account-id $SECURITY_ACCOUNT --region $r
  aws securityhub enable-security-hub --no-enable-default-standards --output text --region $r 

done