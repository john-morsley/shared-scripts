#!/bin/bash

DIRECTORY="$(dirname "$0")"

source ${DIRECTORY}/../common/is_numeric.sh

is_numeric
result=$? 
echo "Is '' numeric? --- $result"

is_numeric 1
result=$? 
echo "Is 1 numeric? --- $result"

is_numeric "1"
result=$? 
echo "Is \"1\" numeric? --- $result"

is_numeric "x"
result=$? 
echo "Is \"x\" numeric? --- $result"

exit 0