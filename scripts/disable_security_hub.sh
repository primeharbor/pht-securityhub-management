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
# Script to disable security hub in all regions in this account.
# Use this with AWS SSO or config profiles to assume roles into the accounts to disable.
#

PROFILE=""

if [ ! -z "$1" ] ; then
	PROFILE="--profile $1"
fi

REGIONS=`aws ec2 describe-regions --query 'Regions[].[RegionName]' --output text  $PROFILE`
for r in $REGIONS ; do
  echo "Disabling Security Hub in ${r}"
  aws securityhub disable-security-hub --region $r  $PROFILE
done