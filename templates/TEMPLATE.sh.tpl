#!/bin/bash

# Copyright © (>>>YEAR<<<)  (>>>COPYRIGHT_HOLDER<<<)
# All Rights Reserved
# 
# author: (>>>AUTHOR<<<)
# maintainer: (>>>AUTHOR<<<)
# 

function usage()
{
    echo >&2 usage: $1 [-s server]
    exit 2
}

while getopts "ds:?" o
do
    case "$o" in 
        d) set -x ;;                    # trace on
        s) server=$OPTARG ;;            # server IP
        ?) usage $0 ;;                  # usage
    esac
done
shift $(($OPTIND-1))

(>>>POINT<<<)


