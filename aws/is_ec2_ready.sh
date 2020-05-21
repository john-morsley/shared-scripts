#!/usr/bin/env bash

#      _____       ______    _____   ___     
#     |_   _|     |  ____|  / ____| |__ \   
#       | |  ___  | |__    | |         ) | 
#       | | / __| |  __|   | |        / /   
#      _| |_\__ \ | |____  | |____   / /_    
#     |_____|___/ |______|  \_____| |____|   
#           _____                _         ___
#          |  __ \              | |       |__ \
#          | |__) |___  __ _  __| |_   _     ) |
#          |  _  // _ \/ _` |/ _` | | | |   / /
#          | | \ \  __/ (_| | (_| | |_| |  |_|
#          |_|  \_\___|\__,_|\__,_|\__, |  (_)
#                                   __/ |       
#                                  |___/        

# Requires:
# - AWS CLI
# - jq

DIRECTORY="$(dirname "$0")"

source ${DIRECTORY}/../common/functions.sh

# Expects:
# 1 --> NAME (Required): The name of the EC2 instance we are checking.
# 2 --> TIMEOUT, in minutes (Optional, default: 5)

header "IS EC2 READY?"

NAME=$1
if [[ -z "${NAME}" ]]; then
    print_normal "No NAME supplied!\n"
    exit 666
fi
print_key_value_pair "NAME" "${NAME}"

TIMEOUT=$2
if [[ -z "${TIMEOUT}" ]]; then
    echo "No TIMEOUT supplied, so defaulting to 5 minutes."
    TIMEOUT=5
fi
print_key_value_pair "TIMEOUT" "${TIMEOUT}" "minutes"

print_divider

print_key_value_pair "Looking for instance" "${NAME}"

elapsed=0
while [[ elapsed -le TIMEOUT*60 ]]
do
  
    reservations_json=$(aws ec2 describe-instances --filter Name=instance-state-code,Values="16")
    # The valid values are: 0 (pending), 16 (running), 32 (shutting-down), 48 (terminated), 64 (stopping), and 80 (stopped). 

    raw_instance_ids="$(jq --raw-output --arg name "$NAME" '.Reservations[].Instances[] as $instance | $instance.Tags[] | select(.Key=="Name") | .Value==$name | contains(true)? | if true then $instance | .InstanceId else null end' <<< $reservations_json)"

    if [[ -z "${raw_instance_ids}" ]]; then
        print_normal "Cannot find instance.\n"
    else
        print_green "Found!\n"
        break
    fi

    print_key_value_pair "Elapsed" "${elapsed}" "s"

    sleep 10
    elapsed=$((elapsed + 10))

done

set -f
IFS='
'
read -rd '' -a split_instance_ids <<< $raw_instance_ids
unset IFS
count=0
for instance_id in "${split_instance_ids[@]}"; do
    print_key_value_pair "Instance ID" "${instance_id}"
    count=$((count + 1))
done
set +f
print_key_value_pair "Count" "${count}"

if [[ count -gt 1 ]]; then
    print_normal "Found more than one instance with name: '${NAME}'"
    echo "IS EC2 NOT READY" "NO"
    exit 666
fi

is_empty() {

    instance_statuses=$1
    
    if [[ -z "$(jq '.InstanceStatuses[]' <<< $instance_statuses)" ]]; then
        return 1
    fi 
    
    return 0

}

function is_ec2_ready() {

    local instance_statuses=$(aws ec2 describe-instance-status --instance-ids $instance_id)

    is_empty "${instance_statuses}"

    if [[ $1 -eq 1 ]]; then
        return 0
    fi
    
    local instance_state=$(jq --raw-output '.InstanceStatuses[].InstanceState.Name' <<< $instance_statuses)
        
    if [[ "$instance_state" != "running" ]]; then
        echo "Instance State: '${instance_state}'"
        return 0
    fi
    
    local instance_status=$(jq --raw-output '.InstanceStatuses[].InstanceStatus.Details[] | select(.Name=="reachability") | .Status' <<< $instance_statuses)
        
    local system_status=$(jq --raw-output '.InstanceStatuses[].SystemStatus.Details[] | select(.Name=="reachability") | .Status' <<< $instance_statuses)
    
    #echo "Instance State: '${instance_state}', Instance Status: '${instance_status}', System Status: '${system_status}'"
    
    print_ec2_status "${instance_state}" "${instance_status}" "${system_status}"
           
    if [[ "$instance_status" != "passed" || "$system_status" != "passed" ]]; then                        
        return 0
    fi
    
    ready=true
    return 1

}

function print_ec2_status() {

    instance_state=$1
    instance_status=$2
    system_status=$3
    
    # The valid values are: 
    # 0 (pending) - blue
    # 16 (running) - green
    # 32 (shutting-down) - yellow 
    # 48 (terminated) - red
    # 64 (stopping) - red
    # 80 (stopped) - red

    print_dim "Instance State: "
    if [[ ${instance_state} == "pending" ]]; then
        print_blue "${instance_state}"
    elif [[ ${instance_state} == "running" ]]; then
        print_green "${instance_state}"
    elif [[ ${instance_state} == "shutting-down" ]]; then
        print_green "${instance_state}"        
    else
        print_red "${instance_state}"
    fi

    print_dim "  |  Instance Status: "
    if [[ ${instance_status} == "passed" ]]; then
        print_green "${instance_status}"        
    else
        print_red "${instance_status}"
    fi
    
    print_dim "  |  System Status: "
    if [[ ${system_status} == "passed" ]]; then
        print_green "${system_status}"        
    else
        print_red "${system_status}"
    fi
    printf "\n"

    #echo "Instance State: '${instance_state}', Instance Status: '${instance_status}', System Status: '${system_status}'"

}

ready=false
while [[ elapsed -le TIMEOUT*60 ]]
do    

    print_key_value_pair "Elapsed" "${elapsed}" "s"
    
    is_ec2_ready

    if [[ $? == 1 ]]; then
        break
    fi

    sleep 5
    elapsed=$((elapsed + 5))

done

if [[ "$ready" == true ]]; then
    footer "IS EC2 READY?" "YES"
    exit 0
fi 

footer "IS EC2 READY?" "NO"
exit 666