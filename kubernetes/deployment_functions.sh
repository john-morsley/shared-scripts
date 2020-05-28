#!/bin/bash

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
DIM=$(tput dim)
BOLD=$(tput bold)

function print_deployment_header() {
  echo "${DIM}-------+----------+-----------+---------+---------------------------------------${NORMAL}"
}

function print_deployment_headers() {  
  print_deployment_header
  echo "${DIM} Ready | Expected | Available | Updated | Deployment${NORMAL}"
  print_deployment_header
}

function print_deployment_row() {
  ready=$1
  expected=$2
  available=$3
  updated=$4
  deployment_name=$5
  
  if [[ "${ready}" -eq "${expected}" && "${expected}" -eq "${available}" ]]; then
    colour=${GREEN}
  else
    colour=${RED}
  fi
  
  ready="${ready}"
                
  printf "${colour}%6d${NORMAL} ${DIM}|${NORMAL} " ${ready}
  printf "${colour}%8d${NORMAL} ${DIM}|${NORMAL} " ${expected}
  printf "${colour}%9d${NORMAL} ${DIM}|${NORMAL} " ${available}
  printf "%7d ${DIM}|${NORMAL} " ${updated}
  printf "%s\n" ${deployment_name}
}

function deployment_statuses () {
  
  deployments=()
  
  local is_ready="Yes"

  local deployments_json=$($GET_DEPLOYMENTS_COMMAND)  
  local number_of_deployments=$(jq '.items | length' <<< $deployments_json)  
  
  for ((i = 0 ; i < number_of_deployments ; i++)); do
   
    deployment_json=$(jq --arg i ${i} '.items[$i|tonumber]' <<< $deployments_json)
    
    deployment_name=$(jq  -r '.metadata.name' <<< $deployment_json)
    
    ready=$(jq '.status.readyReplicas' <<< $deployment_json)    
    if [[ $(is_numeric ${ready}) == "No" ]]; then
      ready=0
    fi
    
    expected=$(jq '.spec.replicas' <<< $deployment_json)
    
    available=$(jq '.status.availableReplicas' <<< $deployment_json)    
    if [[ $(is_numeric ${available}) == "No" ]]; then
      available=0
    fi
            
    updated=$(jq '.status.updatedReplicas' <<< $deployment_json)    
    if [[ $(is_numeric ${updated}) == "No" ]]; then
      updated=0
    fi
      
    deployments[i]="${ready},${expected},${available},${updated},${deployment_name}"          
      
    if [[ ${ready} -ne ${expected} ]]; then
      is_ready="No"  
    fi
      
  done
    
  #bash ${DIRECTORY}/print_deployment_header.sh

  results=""
  for ((i = 0 ; i < number_of_deployments ; i++)); do
    results+="${deployments[i]}|"
  done
  results=${results::-1}    
        
  echo "${is_ready}:${results}"
  
}