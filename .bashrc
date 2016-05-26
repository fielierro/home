# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

unset command_not_found_handle

# Shells append history on exit instead of replacing
shopt -s histappend

#export GIT_EXTERNAL_DIFF=$HOME/bin/gitdiff
export XAUTHORITY=$HOME/.Xauthority


here=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

test -r $here/.bash_aliases && source $here/.bash_aliases
test -r $here/.bash_functions && source $here/.bash_functions

source $here/bin/git-prompt.sh
PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'
