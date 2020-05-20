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