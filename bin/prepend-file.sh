#!/bin/bash

set -e

program=$0
here=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function fatal()
{
    if [ -n "$*" ] ; then
        echo >&2 "$*"
    fi

cat >&2 <<-EOF
	
	usage: $program <file-to-prepend> <files-to-append>*
	
        Prepend a file to one or more additinal files or stdin

	-d|--debug              Enable shell tracing.
	
	EOF
    exit 2
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -d|--debug)
            shift # past argument
            set -x
            ;;

        ?|--help)
            fatal
            ;;

        *)
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

prepend_file="$1"
shift 1

if [ -z "$prepend_file" ]; then
    fatal "The file to prepend must be the first positional parameter"
fi

if [[ $# -eq 0 ]];then
    cat $prepend_file -
else
    for file in $@;do
        backup=${file}.bak
        mv $file $backup
        cat $prepend_file $backup > $file
    done
fi
