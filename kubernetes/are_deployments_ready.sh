#!/usr/bin/env bash

#         /\             
#        /  \   _ __ ___ 
#       / /\ \ | '__/ _ \
#      / ____ \| | |  __/
#     /_/    \_\_|  \___|                       
#           _____             _                                  _       
#          |  __ \           | |                                | |      
#          | |  | | ___ _ __ | | ___  _   _ _ __ ___   ___ _ __ | |_ ___ 
#          | |  | |/ _ \ '_ \| |/ _ \| | | | '_ ` _ \ / _ \ '_ \| __/ __|
#          | |__| |  __/ |_) | | (_) | |_| | | | | | |  __/ | | | |_\__ \
#          |_____/ \___| .__/|_|\___/ \__, |_| |_| |_|\___|_| |_|\__|___/
#                      | |   _____     __/ |      _         ___                               
#                      |_|  |  __ \   |___/      | |       |__ \ 
#                           | |__) |___  __ _  __| |_   _     ) |
#                           |  _  // _ \/ _` |/ _` | | | |   / / 
#                           | | \ \  __/ (_| | (_| | |_| |  |_|  
#                           |_|  \_\___|\__,_|\__,_|\__, |  (_)  
#                                                    __/ |       
#                                                   |___/        

# Requires:
# - kubectl
# - jq

# Expects:
# 1 --> KUBE_CONFIG (Required): The full path and filename to where the 
#                               kube-config YAML file is located.
# 2 --> NAMESPACE (Optional): A Namespace to filter by. 

set -e -o pipefail -u

#set -x

DIRECTORY="$(dirname "$0")"

source ${DIRECTORY}/../common/header.sh
source ${DIRECTORY}/../common/divider.sh
source ${DIRECTORY}/../common/is_numeric.sh
source ${DIRECTORY}/../common/footer.sh
source ${DIRECTORY}/deployment_functions.sh

header "ARE DEPLOYMENTS READY?"

# Parameters...

KUBE_CONFIG=$1
if [[ -z "${KUBE_CONFIG}" ]]; then   
    echo "No KUBE_CONFIG supplied!"
    footer "ARE DEPLOYMENTS READY? *NO*"
    exit 666
fi
echo "KUBE_CONFIG:" ${KUBE_CONFIG}

NAMESPACE=${2:-"ALL"}
if [[ ${NAMESPACE} == "ALL" ]]; then
    echo "No namespace supplied."
    GET_DEPLOYMENTS_COMMAND="kubectl get deployments --all-namespaces --output json"
else
    echo "NAMESPACE:" ${NAMESPACE}
    GET_DEPLOYMENTS_COMMAND="kubectl get deployments --namespace ${NAMESPACE} --output json"
fi
print_divider

# Functions...

print_deployment_status() {

  deployments=$1 
  attempt=$2

  echo "Attempt ${attempt} of 99"

  IFS='|' read -r -a deployments_array <<< "${deployments}"
  
  print_deployment_headers
  for ((i = 0 ; i < ${#deployments_array[*]} ; i++)); do
    IFS=',' read -r -a row <<< "${deployments_array[i]}"
    print_deployment_row ${row[0]} ${row[1]} ${row[2]} ${row[3]} ${row[4]}
  done
  print_deployment_header

}

export KUBECONFIG=${KUBE_CONFIG}

deployments_json=$($GET_DEPLOYMENTS_COMMAND)  
number_of_deployments=$(jq '.items | length' <<< $deployments_json)  

if [[ ${number_of_deployments} == 0 ]]; then 
  echo "No deployments!"
  footer "IS CLUSTER READY? *NO* :-("
  exit 666  
else

#echo "Deployment(s) Status:"
attempt=1
while true; do

  results=$(deployment_statuses)
  if [[ ${results} == "" ]]; then
    echo "All deployment(s) are ready."   
    break
  fi

  if [[ $((attempt)) -gt 99 ]]; then
    echo "Too many attempts, giving up!"   
    break
  fi

  print_deployment_status ${results} ${attempt}  
  attempt=$((attempt+1))
  
  sleep 10

done
  
fi

print_divider
if [[ "${NAMESPACE}" == "ALL" ]]; then
    echo "kubectl get all --all-namespaces"
    print_divider
    kubectl get deployments --all-namespaces    
else
    echo "kubectl get all --namespace ${NAMESPACE}"
    print_divider
    kubectl get deployments --namespace ${NAMESPACE}
fi
print_divider

footer "ARE DEPLOYMENTS READY? *YES*"

# Error Handling...

function error() {  
  local line_number=$1
  local command=$2
  echo "Failed at line: ${line_number}, doing: ${command}"
  header "IS CLUSTER READY? *NO* An unexpected error occurred! :-("
}

trap 'error ${LINENO} $BASH_COMMAND' ERR

exit 0