#!/bin/bash

function footer() { 

  FOOTER_TEXT=$1

  LengthOfFooterText=${#FOOTER_TEXT}

  echo -n "<"
  for (( i=1; i<=78-LengthOfFooterText; i++ ))
  do  
    echo -n "-"
  done
  echo " ${FOOTER_TEXT}"

}