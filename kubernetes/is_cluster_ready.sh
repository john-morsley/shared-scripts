#!/bin/bash

#      _____        _____ _           _              
#     |_   _|      / ____| |         | |            
#       | |  ___  | |    | |_   _ ___| |_ ___ _ __ 
#       | | / __| | |    | | | | / __| __/ _ \ '__| 
#      _| |_\__ \ | |____| | |_| \__ \ ||  __/ |     
#     |_____|___/  \_____|_|\__,_|___/\__\___|_|     
#           _____                _         ___  
#          |  __ \              | |       |__ \ 
#          | |__) |___  __ _  __| |_   _     ) |
#          |  _  // _ \/ _` |/ _` | | | |   / / 
#          | | \ \  __/ (_| | (_| | |_| |  |_|  
#          |_|  \_\___|\__,_|\__,_|\__, |  (_)  
#                                   __/ |       
#                                  |___/        

#set -e -o pipefail -u
#set -e

set -x

# Requires:
# - kubectl
# - jq

DIRECTORY="$(dirname "$0")"
echo "DIRECTORY: ${DIRECTORY}"

source ${DIRECTORY}/../common/error.sh
source ${DIRECTORY}/../common/header.sh
source ${DIRECTORY}/../common/footer.sh

# Expects:
# 1 --> KUBE_CONFIG (Required): The full path and filename to where the 
#                               kube-config YAML file is located.

KUBE_CONFIG=$1

# Error Handling...

function error() {  
  local line_number=$1
  local command=$2
  echo "Failed at line: ${line_number}, doing: ${command}"
  header "IS CLUSTER READY? *NO* An unexpected error occurred! :-("
}

trap 'error ${LINENO} $BASH_COMMAND' ERR

# Parameters...

header "IS CLUSTER READY?"

#bash ${DIRECTORY}/print_divider.sh

if [[ -z "${KUBE_CONFIG}" ]]; then
  echo "No KUBE_CONFIG supplied."
  footer "IS CLUSTER READY? *NO* :-("
  exit 666
fi
echo "KUBE_CONFIG: ${KUBE_CONFIG}"

#bash ${DIRECTORY}/print_divider.sh

export KUBECONFIG=${KUBE_CONFIG}         

function is_cluster_ready () {

    nodes_json=$(kubectl get nodes --output "json" 2>/dev/null)

    if [ -z "$nodes_json" ]; then
      #echo "No"
      #return 1
      echo "NO"
    fi

    number_of_nodes=$(jq '.items | length' <<< $nodes_json)

    if [[ $number_of_nodes == 0 ]]; then
        #echo "No - Number of Nodes: ${number_of_nodes}"
        #return 1
        echo "NO"
    fi

    #feedback="Number of Nodes: ${number_of_nodes} | "

    for ((i = 0 ; i < number_of_nodes ; i++))
    do
        node_json=$(jq --arg i ${i} '.items[$i|tonumber]' <<< $nodes_json)
        node_name=$(jq '.metadata.name' <<< $node_json)
        node_status=$(jq '.status.conditions[] | select(.reason == "KubeletReady") | .type' <<< $node_json)
        #feedback+="Node $((i+1)): ${node_name} | Status: ${node_status}"
    done

    if [[ "${node_status}" == "Ready" ]]; then
        echo "YES"
    fi
    echo "NO"

}  

#bash ${DIRECTORY}/print_divider.sh
echo "kubectl config current-context"
#bash ${DIRECTORY}/print_divider.sh
kubectl config current-context
#bash ${DIRECTORY}/print_divider.sh

echo "Are node(s) up...?"

while true; do

    result=$(is_cluster_ready)

    if [[ "$result" == "YES" ]]; then
        break
    fi

    sleep 10

done

#bash ${DIRECTORY}/print_divider.sh
echo "kubectl cluster-info"
#bash ${DIRECTORY}/print_divider.sh
kubectl cluster-info

#bash ${DIRECTORY}/print_divider.sh
echo "kubectl get nodes"
#bash ${DIRECTORY}/print_divider.sh
kubectl get nodes

#bash ${DIRECTORY}/print_divider.sh

footer "IS CLUSTER READY? *YES* :-)"

#bash ${DIRECTORY}/are_deployments_ready.sh ${FOLDER}

exit 0