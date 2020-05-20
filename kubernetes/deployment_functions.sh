#!/bin/bash

function print_deployment_header() {
  echo "----------+-----------+-----------+-----------+---------------------------------"
}

function print_deployment_headers() {  
  print_deployment_header
  echo "    Ready |  Expected | Available |   Updated | Deployment"
  print_deployment_header
}

function print_deployment_row() {
  ready=$1
  expected=$2
  available=$3
  updated=$4
  deployment_name=$5              
  printf "%9d | %9d | %9d | %9d | %s\n" ${ready} ${expected} ${available} ${updated} ${deployment_name}
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
      
  if [[ "$is_ready" == "Yes" ]]; then
    echo ""
  else
    echo ${results}
  fi 
  
}