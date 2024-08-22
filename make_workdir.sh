#!/bin/bash

TXT_RED="\033[1;31m"
TXT_GREEN="\033[1;32m"
TXT_YELLOW="\033[1;33m"
TXT_BLUE="\033[1;34m"
FANCY_RESET="\033[0m"

set -eu

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

cp -rf ./Part-I/* ./Workdir
cp -rf ./Part-II/{prepare_sys.sh, version-check.sh} ./Workdir

# echo "$TXT_YELLOW"
# read -p "Enter your username, it will be used to name your kernel : " name

# sed -i "s/^CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=\"$new_localversion\"/" ""

mkdir -vp $LFS/Workdir
cp -rf ./Part-III/* $LFS/Workdir/.
rm -rf $LFS/Workdir/dl_blfs_pkg.sh
cp -rf ./Part-II/last_settings.sh $LFS/Workdir/.
chmod 777 $LFS/Workdir/*
chmod 777 Workdir/*

cd Workdir
print_color "$TXT_GREEN" "Everything is set just follow the tutorial"