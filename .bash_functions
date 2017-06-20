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

function git-default-branch()
{
    base=$(repobase)
    for remote in upstream origin;do
        file="$base/.git/refs/remotes/$remote/HEAD"
        if [ -f "$file" ]; then
            grep -o < "$file" -e '\w*$'
            return $?
        fi
    done
    return 1
}

function swap()
{
    # function to swap two file's names
    local readonly TMPFILE=tmp.$$
    mv "$1" $TMPFILE
    mv $2 "$1"
    mv $TMPFILE "$2"
}

function gitbr()
{
    git symbolic-ref HEAD | sed 's|refs/heads/||'
}

function lsbr()
{
    local head="cat"
    local verbose=""
    local description=""
    local short=""

    # Parse through for -s and -<number>
    for arg in $@; do
        if [ "$arg" == "-v" ] ||  [ "$arg" == "--verbose" ]; then
            verbose=true
            short=""
        elif [ "$arg" == "-b" ] ||  [ "$arg" == "--brief" ]; then
            short=true
            verbose=""
        elif [ "$arg" == "-?" ] || [ "$arg" == "--help" ]; then
            echo >&2 "usage: $FUNCNAME [-v|--verbose] [-b|--brief]"
            return 0
        elif [[ $arg =~ \-[0-9]+ ]]; then
            head="head $arg"
        else
            echo >&2 "$FUNCNAME: Unrecognized parameter: $arg"
            return 2
        fi
    done

    # List the branches in the local repository
    local readonly basedir="$(repobase)"
    if [ -z "$basedir" ] ; then
        echo >&2 "$FUNCNAME: Must run in a git repo or export REPOHOME"
        return 1
    fi

    (
        # Look up each branch and print its info
        cd "$basedir"
        for k in $(git branch | sed s/^..//);
        do
            if [ -n "$verbose" ]; then
                description="$(git config branch.$k.description)"
            fi
            if [ -z "$short" ]; then
                printf "%s %-40s %s\n" "$(git --no-pager log --pretty="format:%ci" -1 $k)" $k "$description"
            else
                echo $k
            fi
        done | sort -r | $head | sed 's/[ ]*$//'
    )
}

function git-describe()
{

    local readonly br="$1"
    local readonly desc="$2"

    if [ -z "$br" ] || [ -z "$desc" ] ; then
        echo >&2 "$FUNCNAME: git-describe <branch-name> <description>"
        return 1
    fi
    git config branch.${br}.description "$desc"
}


function gcd()
{
    local br="$1"
    if [ -z "$br" ] ; then
        br="$(git-default-branch)" || br=development
    fi

    if git checkout "$br" ; then

        br=$(git symbolic-ref HEAD | sed 's|refs/heads/||')
        local readonly description="$(git config branch.$br.description)"
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
    local readonly op="$1"
    shift 1

    local args=()
    while [[ $1 == -* ]]; do
        args+="$1"
        shift 1
    done

    local repos="$1"

    if [ "$op" != "push" -a  "$op" != "pull"  -a "$op" != "pull --rebase" ] ; then
        echo >&2 "$FUNCNAME usage: push|pull [repo]"
        false
    fi

    if [ -z "$repos" ] ; then
        repos="origin"
    elif [ "$repos" == "-a" ] ; then
        repos="$(git remote)" || (echo >&2 "$FUNCNAME: Failed to list remote repositories" && return 2)
    fi

    local saved_branch_name="$(git symbolic-ref HEAD 2>/dev/null)" || saved_branch_name="DETACHED"     # detached HEAD
    if [ "$saved_branch_name" == "DETACHED" ] ; then
        echo >&2 "$FUNCNAME: Cannot push in branch with detached head"
        false
    else
        saved_branch_name="${saved_branch_name##refs/heads/}"
        for repo in $repos; do
            local cmd="git $op $args $repo $saved_branch_name"
            echo "$cmd"
            $cmd
        done
    fi

}

function repush()
{
    gitpushpull push $@
}

function repull()
{
    gitpushpull "pull" $@
}

function rerebase()
{
    local readonly repo="${1-upstream}"
    gitpushpull "pull --rebase" "$repo"
}

function githome()
{
    local wd=$(repobase)
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
function nextcounter()
{
    if [ -z "$KEYED_COUNTER_API" ] ;then
        echo >&2 "$FUNCNAME: No KEYED_COUNTER_API key in environment"
    elif [ -z "$1" ] ; then
        echo >&2 "$FUNCNAME: Missing counter name"
    else
        curl -X GET --header "x-api-key: $KEYED_COUNTER_API"  "https://a4v28pxam0.execute-api.us-east-1.amazonaws.com/prod/getNextCount?counter=$1"
    fi
}

function git-branch-delete-all()
{
    local br="$1"
    local repos
    local found=""
    shift 1

    if [ -z "$1" ]; then
        repos="$(git remote)" || (echo >&2 "$FUNCNAME: Failed to list remote repositories" && return 2)
    else
        repos="$*"
    fi

    if [ -z "$br" ]; then
        echo >&2 "usage: $FUNCNAME <branch-name>"
        return 1
    fi
    for repo in $repos; do
        git ls-remote --exit-code $repo $br &>/dev/null && git push $repo :$br && found=true
    done
    git rev-parse --verify --quiet $br &>/dev/null && git branch -D $br && found=true
    if [ -z "$found" ] ; then
        echo >&2 "$FUNCNAME: $br not found locally or in a remote repository"
        return 1
    fi

}

function git-jira-branch()
{
    local readonly default_branch="$(basename $(git symbolic-ref HEAD))"
    local readonly ticket="$1"
    local readonly branch="${2:-$default_branch}"
    local readonly repo="${3-upstream}"


    if [ -z "$ticket" ];then
        echo >&2 "$FUNCNAME: usage <jira-id> <branch> <repo>"
        return 1
    fi

    if ! jira --version &>/dev/null;then
        echo >&2 "$FUNCNAME: Missing jira CLI.  Install from https://www.npmjs.com/package/jira-cmd"
        return 1
    fi

    local readonly summary="$(jira show --output summary $ticket)"
    if [ "$summary" ==  'Issue Does Not Exist' ] ;then
        echo >&2 "$FUNCNAME: Could not retrieve issue $ticket"
        return 2
    fi

    local readonly type=$(jira show -o issuetype $ticket)
    if [ "$type" == "Bug" ] ;then
        local readonly new_branch="bugfix/$USER-$ticket"
    else
        local readonly new_branch="feature/$USER-$ticket"
    fi

    if git rev-parse --verify $new_branch &>/dev/null; then
        echo >&2 "$FUNCNAME: Branch already exists: $new_branch"
        return 4
    fi

    if [ -z "$(git ls-remote $repo $branch)" ] ; then
        echo >&2 "$FUNCNAME: Remote not found: $repo/$branch"
        return 5
    fi

    git fetch $repo $branch && git checkout -b "$new_branch" $repo/$branch
    git config branch.${new_branch}.description "$summary"
}

function venv()
{
    local readonly name="$1"
    local readonly dirname="$HOME/virtualenv/$name"
    if [ -z "$name" ];then
        echo >&2 "$FUNCNAME: usage <directory-name>"
        return 1
    fi

    if [ ! -d "$dirname" ];then
        echo >&2 "$FUNCNAME: directory not found: $dirname"
        return 1
    fi

    if [ ! -f "$dirname/bin/activate" ];then
        echo >&2 "$FUNCNAME: directory is not a virtualenv: $dirname"
        return 1
    fi

    source "$dirname/bin/activate"
}
