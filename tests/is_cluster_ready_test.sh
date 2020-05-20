#!/bin/bash

DIRECTORY="$(dirname "$0")"

KUBE_CONFIG=~/.kube/config

bash ${DIRECTORY}/../kubernetes/is_cluster_ready.sh ${KUBE_CONFIG}

exit 0