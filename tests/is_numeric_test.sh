#!/bin/bash

DIRECTORY="$(dirname "$0")"

source ${DIRECTORY}/../common/is_numeric.sh


result=$(is_numeric)
echo "Is '' numeric? --- ${result}"

result=$(is_numeric "")
echo "Is '' numeric? --- ${result}"

result=$(is_numeric '')
echo "Is '' numeric? --- ${result}"

result=$(is_numeric 1) 
echo "Is 1 numeric? --- ${result}"

result=$(is_numeric "1") 
echo "Is \"1\" numeric? --- $result"

#is_numeric "x"
#result=$?
#echo "Is \"x\" numeric? --- $result"
#
#is_numeric "x"
#if [[ $? == 1 ]]; then
#  echo "Is \"x\" numeric? --- Yes"
#else
#  echo "Is \"x\" numeric? --- No"
#fi 
#
#is_numeric "123"
#if [[ $? == 1 ]]; then
#  echo "Is \"123\" numeric? --- Yes"
#else
#  echo "Is \"123\" numeric? --- No"
#fi 

exit 0