#!/bin/bash

#      _____           _        _ _              
#     |_   _|         | |      | | |            
#       | |  _ __  ___| |_ __ _| | | 
#       | | | "_ \/ __| __/ _` | | |
#      _| |_| | | \__ \ || (_| | | |   
#     |_____|_| |_|___/\__\__,_|_|_|   
#           _____             _             
#          |  __ \           | |            
#          | |  | | ___   ___| | _____ _ __ 
#          | |  | |/ _ \ / __| |/ / _ \ "__|
#          | |__| | (_) | (__|   <  __/ |   
#          |_____/ \___/ \___|_|\_\___|_|   

set -e -o pipefail -u

echo "------------------------------------------------------------> INSTALLING DOCKER"

PID=$$
echo "PID: ${PID}"
            
SCRIPT_NAME=$(basename $0)
echo "SCRIPT_NAME: ${SCRIPT_NAME}"

{
  echo "Download the Docker install script and execute it..."
  curl https://releases.rancher.com/install-docker/19.03.sh | sh
  echo "Add the user 'ubuntu' to the group 'docker'..."
  sudo usermod -aG docker ubuntu
  
} || {
  echo "-----------------------------------------> FAILED TRYING TO INSTALL DOCKER! :-(" 1>&2
  exit 666
}

function error() {
  JOB="$0"
  LAST_LINE="$1"
  LAST_ERROR="$2"
  echo "ERROR in ${JOB} : line ${LAST_LINE} with exit code ${LAST_ERROR}"  
  exit 666
}

trap "error ${LINENO} ${?}" ERR

echo "-------------------------------------------------------------> DOCKER INSTALLED"

exit 0