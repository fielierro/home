#!/bin/bash

function swap()
{
    # function to swap two file's names
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE
    mv $2 "$1"
    mv $TMPFILE "$2"
}

function co()
{
    # function to perform a git checkout and set the prompt with the branch name
    git checkout $1 && gitbr=$1 && PS1="\t \u(${gitbr}):\w\$ " 
}

function gsl()
{
    # function to start the specified program under gdbserver
    pgm=$1
    shift
    cmd="gdbserver localhost:5000 $pgm --catch_system_errors=no $*"
    echo $cmd
    $cmd
}

function mkbr()
{
    # Function to create a new git branch, track it upstream, and put the branchname in the prompt
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
    # Make a directory and change to it
    mkdir $1 && cd $1
}

function gitbr()
{
    # Set the prompt to have username, git branch, and working directory
    gitbr=$(cd $REPOHOME  && git branch 2>/dev/null | awk '/\*/{print $2;}')
    PS1="\t \u(${gitbr}):\w\$ " 
}

function lsbr()
{
    # List the branches in the local repository
    (cd $REPOHOME;for k in $(git branch | sed s/^..//);do printf "%s %s\n" "$(git --no-pager log --pretty="format:%ci" -1 $k)" $k;done | sort -r)
}

function gitfiles
{
    # List git modified and added files as a bare list of file names (eg, for tar)
    git --no-pager diff --name-status | awk '/^[AM]/{print $2;}'
}

function repush()
{
    repo="$1"
    if [ -z "$repo" ] ; then
        repo="origin"
    fi

    local saved_branch_name="$(git symbolic-ref HEAD 2>/dev/null)" || saved_branch_name="DETACHED"     # detached HEAD
    if [ "$saved_branch_name" == "DETACHED" ] ; then
        echo >&2 "Cannot push in branch with detached head"
    else 
        saved_branch_name="${saved_branch_name##refs/heads/}"
        cmd="git push $repo $saved_branch_name"
        echo "$cmd"
        $cmd
    fi

}