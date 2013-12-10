#!/bin/bash

function swap()
{
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE
    mv $2 "$1"
    mv $TMPFILE "$2"
}

function co()
{
    git checkout $1 && gitbr=$1 && PS1="\t \u(${gitbr}):\w\$ " 
}

function lscore()
{
    cores=`find . -name 'core.*' -print`
    if [ -n "$cores" ] ; then
        ls -lt $cores
    fi
}

function rmcore()
{
    cores=`find . -type f -name 'core.*' -print`
    if [ -n "$cores" ] ; then
        rm -f $cores
    fi
}

function gsl()
{
    pgm=$1
    shift
    cmd="gdbserver localhost:5000 $pgm --catch_system_errors=no $*"
    echo $cmd
    $cmd
}

function mkbr()
{
    if [ -z "$1" -o -z "$2" ] ; then
        echo >&2 "usage: mkbr <base-branch> <new-branch-name>"
        return
    fi

    base=$1
    br=$2
    git fetch && git checkout $base && git merge origin/$base && git checkout -b $br && git push origin $br && git branch --set-upstream $br origin/$br && gitbr=$br && PS1="\t \u(${gitbr}):\w\$ "
}

function mcd()
{
    mkdir $1 && cd $1
}

function gitbr()
{
    gitbr=$(cd $REPOHOME  && git branch 2>/dev/null | awk '/\*/{print $2;}')
    PS1="\t \u(${gitbr}):\w\$ " 
}

function lsbr()
{
    (cd $REPOHOME;for k in $(git branch | sed s/^..//);do printf "%s %s\n" "$(git --no-pager log --pretty="format:%ci" -1 $k)" $k;done | sort -r)
}

function gitfiles
{
    git --no-pager diff --name-status | awk '/^[AM]/{print $2;}'
}
