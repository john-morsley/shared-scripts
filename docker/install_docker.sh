#!/usr/bin/env bash

#      _____           _        _ _              
#     |_   _|         | |      | | |            
#       | |  _ __  ___| |_ __ _| | | 
#       | | | '_ \/ __| __/ _` | | |
#      _| |_| | | \__ \ || (_| | | |   
#     |_____|_| |_|___/\__\__,_|_|_|   
#           _____             _             
#          |  __ \           | |            
#          | |  | | ___   ___| | _____ _ __ 
#          | |  | |/ _ \ / __| |/ / _ \ '__|
#          | |__| | (_) | (__|   <  __/ |   
#          |_____/ \___/ \___|_|\_\___|_|   

#DIRECTORY="$(dirname "$0")"

#source ${DIRECTORY}/../common/header.sh
                                                                 
#header 'INSTALLING DOCKER'

curl https://releases.rancher.com/install-docker/19.03.sh | sh

sudo usermod -aG docker ubuntu

#header 'DOCKER INSTALLED'

exit 0