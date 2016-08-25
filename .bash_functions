#!/bin/bash

function repobase()
{
    local repobase=""
    if [ -n "$REPOHOME" ] ; then
        repobase=$REPOHOME
    elif git rev-parse --show-toplevel &>/dev/null; then
        repobase=$(git rev-parse --show-toplevel)
    fi
    echo $repobase
}

function swap()
{
    # function to swap two file's names
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE
    mv $2 "$1"
    mv $TMPFILE "$2"
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

function gitbr()
{
    git symbolic-ref HEAD | sed 's|refs/heads/||'
}

function lsbr()
{
    # List the branches in the local repository
    local basedir="$(repobase)"
    if [ -z "$basedir" ] ; then
        echo >&2 "Must run in a git repo or export REPOHOME"
        return 1
    fi

    # Allow line count args for head like "lsbr -4" to pipe to "head -4"
    head="cat"
    if [ -n "$1" ]; then
        head="head $1"
    fi
    (cd "$basedir";for k in $(git branch | sed s/^..//);do printf "%s %-40s %s\n" "$(git --no-pager log --pretty="format:%ci" -1 $k)" $k "$(git config branch."$k".description)";done | sort -r | $head | sed 's/[ ]*$//' )
}

function git-describe()
{

    br="$1"
    desc="$2"

    if [ -z "$br" ] || [ -z "$desc" ] ; then
        echo >&2 "git-describe <branch-name> <description>"
        return 1
    fi
    git config branch.${br}.description "$desc"
}


function gcd()
{
    br="$1"
    if [ -z "$br" ] ; then
        br="development"
    fi

    if git checkout "$br" ; then

        br=$(git symbolic-ref HEAD | sed 's|refs/heads/||')
        description="$(git config branch.$br.description)"
        if [ -n "$description" ] ; then
            echo "$description"
        fi

        br=$(git symbolic-ref HEAD  | awk -F/ '{print $NF;}')
        if [[ $? == 0 ]] ; then
            export CZ_TAG="$br"
        fi
    fi
}


function gitfiles
{
    # List git modified and added files as a bare list of file names (eg, for tar)
    git --no-pager diff --name-status | awk '/^[AM]/{print $2;}'
}

function gitpushpull()
{
    op="$1"
    repos="$2"

    if [ "$op" != "push" -a  "$op" != "pull"  -a "$op" != "pull --rebase" ] ; then
        echo >&2 "$0 usage: push|pull [repo]"
        false
    fi

    if [ -z "$repos" ] ; then
        repos="origin"
    elif [ "$repos" == "-a" ] ; then
        repos=$(git remote) || (echo >&2 "Failed to fetch git remotes" && return)
    fi

    local saved_branch_name="$(git symbolic-ref HEAD 2>/dev/null)" || saved_branch_name="DETACHED"     # detached HEAD
    if [ "$saved_branch_name" == "DETACHED" ] ; then
        echo >&2 "Cannot push in branch with detached head"
        false
    else
        saved_branch_name="${saved_branch_name##refs/heads/}"
        for repo in $repos; do
            cmd="git $op $repo $saved_branch_name"
            echo "$cmd"
            $cmd
        done
    fi

}

function repush()
{
    gitpushpull push $1
}

function repull()
{
    gitpushpull "pull" $1
}

function rerebase()
{
    gitpushpull "pull --rebase" $1
}

function githome()
{
    wd=$(repobase)
    [[ $? == 0 ]] && cd "$wd"
}

function eth0()
{
    ifconfig -a | awk '$1=="inet" {print $2;}' | grep -v '^127\.' | head -1
}

function git-standup()
{
    local author=$(git config --get user.email)
    local since="yesterday"
    if [[ "Mon" == "$(date +%a)" ]]; then
        since="last friday"
    fi
    git --no-pager log --reverse --branches --since="$since" --author="$author" --format=format:'%C(cyan) %ad %C(yellow)%h %Creset %s %Cgreen%d' --date=local && echo ""
}

function pingip()
{
    ping -c 1 $1 | grep ^PING | sed 's/^.*(\([0-9\.]*\)).*$/\1/'
}
