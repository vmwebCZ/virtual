#!/bin/bash
source common.sh

s='test_domain'

id="$( cut -d '_' -f 1 <<< "$s" )"
echo "$id"

#mysql=$(cat addproject/new_user.sql | sed "s|demo|$database|g")
#echo $mysql
