#!/bin/bash
TXT_RED="\033[1;31m"
TXT_GREEN="\033[1;32m"
TXT_YELLOW="\033[1;33m"
TXT_BLUE="\033[1;34m"
FANCY_RESET="\033[0m"

print_color () {
    echo -e "$1$2$FANCY_RESET"
}

user=$(whoami)

if [ $user != "root" ]; then 
    echo -e "Please, Load this script with root\n"
    exit 1
fi

handle_error() {
    print_color "$TXT_RED" "Error: line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

mkdir -vp Workdir

cp -rf ./Utils ./Workdir/.
cp -rf ./Part-I/* ./Workdir/.
cp -rf ./Part-II/* ./Workdir/.
cp -rf ./Part-III/* ./Workdir/.
cp -rf ./Part-IV/* ./Workdir/.

