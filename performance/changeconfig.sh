#!/bin/bash 

# args check
usage() {
    echo "Usage: $0 <orig|fast>" 1>&2; exit 1;
}

t=$1
if [[ -z ${t} ]]; then
    usage
elif ! [[ ${t} == "orig" || ${t} == "fast" ]]; then
    usage
fi

echo $t

cd config
cp sqld360_0a_main_$1.sql ../sql/sqld360_0a_main.sql
cd ..
