#!/bin/bash

# Copyright © 2013 SimpliVT Corporation
# All Rights Reserved
# 
# author: neil.swinton@simplivt.com
# maintainer: neil.swinton@simplivt.com
# 

# Script to create bash, gdb, and emacs configuration files that do nothing but
# source files from a specified list of directories.  For example, getting setup
# from both a work and a home repository.

function usage()
{
    echo >&2 usage: $1 [-n] directory...
    exit 2
}

# Make a backup copy if requested
function backup()
{
    file=$1
    if [ -f "$file" ] ; then
        test -e $file.old && rm -f $file.old 
        mv $file $file.old 
    fi
}

while getopts "dn?" o
do
    case "$o" in 
        d) set -x ;;                    # trace on
        n) nobackup=true;;              # don't make a backup
        ?) usage $0 ;;                  # usage
    esac
done
shift $(($OPTIND-1))

bashfiles=".bash_aliases .bash_functions .bash_profile .bashrc"
dirs="$*"

if [ -z "$dirs" ] ; then
    usage $0
fi

for d in $dirs
do
    if [ ! -d "$HOME/$d" ] ; then
        echo "Directory not found: $HOME/$d"
        usage $0
    fi
done


for f in $bashfiles
do
    if [ -z "$nobackup" ] ; then
        backup $HOME/$f
    else
        rm - $HOME/$f
    fi

    echo "#!/bin/bash" > $HOME/$f
    echo "" >> $HOME/$f
    chmod +x $HOME/$f
done



# prologue for .bashrc
cat >>$HOME/.bashrc <<EOF
if [ -z "\$BASH_PROFILE_READ" ] ; then
    . $HOME/.bash_profile"
fi

. /etc/bash.bashrc
EOF

# prologue for .bash_profile
echo>>$HOME/.bash_profile "export \$BASH_PROFILE_READ=\$\$"

# bash common parts
for f in $bashfiles
do
    for d in $dirs
    do
        echo ". $HOME/$d/$f" >> $HOME/$f
    done
done

for f in .gdbinit
do
    if [ -z "$nobackup" ] ; then
        backup $HOME/$f
    fi

    for d in $dirs
    do
        echo "source $HOME/$d/$f" >> $HOME/$f
    done
done

for f in .emacs
do
    if [ -z "$nobackup" ] ; then
        backup $HOME/$f
    fi

    for d in $dirs
    do
        echo "(load \"$HOME/$d/$f\")" >> $HOME/$f
    done
done



