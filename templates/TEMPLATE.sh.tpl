#!/bin/bash

# Copyright © (>>>YEAR<<<)  (>>>COPYRIGHT_HOLDER<<<)
# All Rights Reserved
#
# author: (>>>AUTHOR<<<)
# maintainer: (>>>AUTHOR<<<)
#

program=$0

function fatal()
{
    if [ -n "$*" ] ; then
        echo >&2 "$*"
    fi

    echo >&2 "usage: $program"
    exit 2
}

while getopts "d?" o
do
    case "$o" in
        d) set -x ;;                    # trace on
        ?) fatal ;;                     # usage
    esac
done
shift $((OPTIND - 1))

(>>>POINT<<<)
