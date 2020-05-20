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

# Requires:
# - kubectl
# - jq

# Expects:
# 1 --> KUBE_CONFIG (Required): The full path and filename to where the 
#                               kube-config YAML file is located.

set -e -o pipefail -u

DIRECTORY="$(dirname "$0")"

source ${DIRECTORY}/../common/error.sh
source ${DIRECTORY}/../common/divider.sh
source ${DIRECTORY}/../common/header.sh
source ${DIRECTORY}/../common/footer.sh

header "IS CLUSTER READY?"

# Parameters...

KUBE_CONFIG=$1
if [[ -z "${KUBE_CONFIG}" ]]; then
  echo "No KUBE_CONFIG supplied!"
  footer "IS CLUSTER READY? *NO* :-("
  exit 666
fi
echo "KUBE_CONFIG: ${KUBE_CONFIG}"

# Functions...

function is_cluster_ready () {

    nodes_json=$(kubectl get nodes --output "json" 2>/dev/null)

    if [ -z "$nodes_json" ]; then
      echo "NO"
      return 0
    fi

    number_of_nodes=$(jq '.items | length' <<< $nodes_json)

    if [[ $number_of_nodes == 0 ]]; then
        #echo "No - Number of Nodes: ${number_of_nodes}"
        echo "NO"
        return 0
    fi

    #feedback="Number of Nodes: ${number_of_nodes} | "

    for ((i = 0 ; i < number_of_nodes ; i++))
    do
        node_json=$(jq --arg i ${i} '.items[$i|tonumber]' <<< $nodes_json)
        node_name=$(jq '.metadata.name' <<< $node_json)
        node_status=$(jq --raw-output '.status.conditions[] | select(.reason == "KubeletReady") | .type' <<< $node_json)
        #feedback+="Node $((i+1)): ${node_name} | Status: ${node_status}"
    done

    #echo ${node_status}
    if [[ "${node_status}" == "Ready" ]]; then
        echo "YES"
        return 0            
    fi

    echo "NO"
    return 0

}  

export KUBECONFIG=${KUBE_CONFIG}
print_divider
current_context=$(kubectl config current-context)
echo "kubectl config current-context: ${current_context}"
print_divider

echo "Are node(s) up...?"
while true; do

    result=$(is_cluster_ready)

    if [[ "$result" == "YES" ]]; then
        echo "Yes"
        break
    fi

    echo "No"
    sleep 10

done

print_divider
echo "kubectl cluster-info"
print_divider
kubectl cluster-info

print_divider
echo "kubectl get nodes"
print_divider
kubectl get nodes

footer "IS CLUSTER READY? *YES* :-)"

# Error Handling...

function error() {  
  local line_number=$1
  local command=$2
  echo "Failed at line: ${line_number}, doing: ${command}"
  header "IS CLUSTER READY? *NO* An unexpected error occurred! :-("
}

trap 'error ${LINENO} $BASH_COMMAND' ERR

exit 0