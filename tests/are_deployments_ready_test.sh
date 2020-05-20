#!/bin/bash

# To add a test deployment...
# kubectl create deployment hello-world --image hello-world
#
#
#

DIRECTORY="$(dirname "$0")"

KUBE_CONFIG=~/.kube/config

bash ${DIRECTORY}/../kubernetes/are_deployments_ready.sh ${KUBE_CONFIG}

exit 0