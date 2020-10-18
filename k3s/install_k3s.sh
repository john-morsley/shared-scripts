#!/bin/bash

#      _____           _        _ _              
#     |_   _|         | |      | | |            
#       | |  _ __  ___| |_ __ _| | | 
#       | | | "_ \/ __| __/ _` | | |
#      _| |_| | | \__ \ || (_| | | |   
#     |_____|_| |_|___/\__\__,_|_|_|   
#           _  ______      
#          | |/ /___ \     
#          | ' /  __) |___ 
#          |  <  |__ </ __|
#          | . \ ___) \__ \
#          |_|\_\____/|___/

set -e -o pipefail -u

echo "------------------------------------------------------------> INSTALLING K3S"

PID=$$
echo "PID: ${PID}"
            
SCRIPT_NAME=$(basename $0)
echo "SCRIPT_NAME: ${SCRIPT_NAME}"

{
  echo "Download the K3s install script and execute it..."
  curl -sfL https://get.k3s.io | sh -  
} || {
  echo "-----------------------------------------> FAILED TRYING TO INSTALL K3S! :-(" 1>&2
  exit 255
}

function error() {
  JOB="$0"
  LAST_LINE="$1"
  LAST_ERROR="$2"
  echo "ERROR in ${JOB} : line ${LAST_LINE} with exit code ${LAST_ERROR}"  
  exit 255
}

trap "error ${LINENO} ${?}" ERR

echo "-------------------------------------------------------------> K3S INSTALLED"

exit 0