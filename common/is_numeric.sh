#!/bin/bash

function is_numeric() { 

  NUMBER=$1

  if [ "$1" -eq "$1" ] 2>/dev/null; then
    return 1
  fi

  return 0
}