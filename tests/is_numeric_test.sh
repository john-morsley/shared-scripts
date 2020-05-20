#!/bin/bash

DIRECTORY="$(dirname "$0")"

source ${DIRECTORY}/../common/is_numeric.sh

is_numeric
result=$(is_numeric)
echo "Is '' numeric? --- $result"

result=$(is_numeric 1) 
echo "Is 1 numeric? --- $result"

result=$(is_numeric "1") 
echo "Is \"1\" numeric? --- $result"

result=$(is_numeric "x")
echo "Is \"x\" numeric? --- $result"

if [[ $(is_numeric "x") == "YES" ]]; then
  echo "Is \"x\" numeric? --- Yes"
else
  echo "Is \"x\" numeric? --- No"
fi 

if [[ $(is_numeric "123") == "YES" ]]; then
  echo "Is \"123\" numeric? --- Yes"
else
  echo "Is \"123\" numeric? --- No"
fi 

exit 0