#!/bin/bash
  
DIM=$(tput dim)
NORMAL=$(tput sgr0)  
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)

function error() {
  JOB="$0"
  LAST_LINE="$1"
  LAST_ERROR="$2"
  echo "ERROR in ${JOB} : line ${LAST_LINE} with exit code ${LAST_ERROR}"  
  exit 666
}

function footer() { 

  FOOTER_TEXT=$1
  STATUS=${2:-"OK"}

  length_of_footer_text=${#FOOTER_TEXT}
  length_of_footer_status=${#STATUS}

  printf "<"
  for (( i=1; i<=77-length_of_footer_text-length_of_footer_status; i++ ))
  do  
    printf "="
  done 
  status_colour=${YELLOW}    
  
  if [[ ${STATUS} == "YES" ]]; then
    status_colour=${GREEN}
  elif [[ ${STATUS} == "NO" ]]; then
    status_colour=${RED}
  elif [[ ${STATUS} == "ERROR" ]]; then
    status_colour=${RED}
  fi
  printf " ${BOLD}${FOOTER_TEXT}${NORMAL} ${status_colour}${STATUS}${NORMAL}\n"

}

function header() { 

  HEADER_TEXT=$1

  LengthOfHeaderText=${#HEADER_TEXT}

  for (( i=1; i<=78-LengthOfHeaderText; i++ ))
  do  
     printf "="
  done
  printf "> ${BOLD}${HEADER_TEXT}${NORMAL}\n"

}

function is_numeric() { 

  NUMBER=$1

  if [ "$1" -eq "$1" ] 2>/dev/null; then
    echo "Yes"
  else
    echo "No"  
  fi

}

function print_blue {
  TEXT=$1  
  printf "${BLUE}${TEXT}${NORMAL}"
}

function print_dim {
  TEXT=$1  
  printf "${DIM}${TEXT}${NORMAL}"
}

function print_divider {  
  printf "${DIM}--------------------------------------------------------------------------------${NORMAL}\n"
}

function print_key_value_pair {
  KEY=$1
  VALUE=$2  
  UNITS=${3:-""}
  printf "${DIM}${KEY}: ${NORMAL}${VALUE} ${DIM}${UNITS}${NORMAL}\n"
}

function print_green {
  TEXT=$1  
  printf "${GREEN}${TEXT}${NORMAL}"
}

function print_normal {
  TEXT=$1  
  printf "${DIM}${TEXT}${NORMAL}"
}

function print_red {
  TEXT=$1  
  printf "${RED}${TEXT}${NORMAL}"
}

function print_yellow {
  TEXT=$1  
  printf "${YELLOW}${TEXT}${NORMAL}"
}
