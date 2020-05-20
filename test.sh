#!/usr/bin/env bash

DIRECTORY="$(dirname "$0")"

source ${DIRECTORY}/common/header.sh
source ${DIRECTORY}/common/footer.sh

header "Test"

echo "Hello, World! :-)"

footer "Test"

exit 0