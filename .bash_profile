# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022


export TZ=${TZ:-"/usr/share/zoneinfo/US/Eastern"}

# Bash History -- big and timestamped
export HISTSIZE=5000
export HISTFILESIZE=10000
export HISTTIMEFORMAT="%F %R %Z "

# English if available
LANG="C"
if locale -a 2>/dev/null | grep --silent "^en";then
    export LANG=en
    export LC_MESSAGES=en
fi

here=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
test -d $here/bin && export PATH="$PATH:$here/bin"
