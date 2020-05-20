#!/bin/bash

set -x

if [[ "YES" == "YES" ]]; then
  echo "Equal 1"
else
  echo "Not Equal 1"
fi

test1="\"YES\""
echo "${test1}"
test1=$(echo "${test1}" | jq --raw-output .)
echo "${test1}"
if [[ ${test1} == "YES" ]]; then
  echo "Are Equal 2"
else
  echo "Not Equal 2"
fi
