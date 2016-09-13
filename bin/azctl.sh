#!/bin/bash

# Copyright © 2016  Neil Swinton
# All Rights Reserved
#
# author: neil@cazena.com
# maintainer: neil@cazena.com
#

program=$0

function fatal()
{
    if [ -n "$*" ] ; then
        echo >&2 "$*"
    fi

    echo >&2 "usage: $program [-t tagname=tagvalue] <operation> <pattern>"
    exit 2
}

while getopts "dt:?" o
do
    case "$o" in
        d) set -x ;;                    # trace on
        t) tags="$OPTARG" ;;            # -t Persist=True
        ?) usage ;;                     # usage
    esac
done
shift $((OPTIND - 1))

readonly op="$1"
readonly pattern="$2"

# Check parameters
if [ -z "$op" ] ;then
    fatal "Missing operation parameter"
fi

if [ -z "$pattern" ] ;then
    fatal "Missing pattern parameter"
fi

# Loop through the resource groups, then vm's within them
rgs=$(azure group list | awk "\$2~/neil/{print \$2;}")
for rg in $rgs; do

    if [ -n "$tags" ] ; then
        azure group set -n "$rg" -t "$tags"
    fi

    azure vm list -g "$rg"
    vms=$(azure vm list -g "$rg" | awk  "\$3 == \"Succeeded\" {print \$2;}")
    if [ "$op" != "list" ] ; then
        for vm in $vms; do
            azure vm $op -g $rg -n "$vm" &
        done
    fi
done
wait
