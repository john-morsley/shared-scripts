#!/bin/bash

function is_numeric() { 

  NUMBER=$1

  if [ "$1" -eq "$1" ] 2>/dev/null; then
    echo "YES"
    return 
  fi

  echo "NO"
  return 0
}