# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/personal/home/.bash_aliases ]; then
    . ~/personal/home/.bash_aliases
fi

# Include my functions
if [ -f ~/personal/home/.bash_functions ]; then
    . ~/personal/home/.bash_functions
fi


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export SVTHOME=$HOME/rfs
export SVTBUILD=/var/tmp/build
gitbr=$(cd $SVTHOME  && git branch 2>/dev/null | awk '/\*/{print $2;}')
if [ -n "$gitbr" ]
then
    export gitbr
    PS1='\t \u(${gitbr}):\w\$ '
fi

unset command_not_found_handle

#export GIT_EXTERNAL_DIFF=$HOME/bin/gitdiff
export XAUTHORITY=$HOME/.Xauthority 
