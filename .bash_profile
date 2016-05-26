# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022


export TZ=${TZ:-"/usr/share/zoneinfo/US/Eastern"}
export HISTSIZE=5000
export HISTFILESIZE=10000

here=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
test -d $here/bin && export PATH="$PATH:$here/bin"

# Create a template ssh-config
if [ -d ~/.ssh -a -f ~/.ssh/id_rsa -a ! -f ~/.ssh/config ] ; then
    cat > ~/.ssh/config <<EOF
IdentityFile ~/.ssh/id_rsa

# Host example
#      HostName 10.9.131.250
#      ForwardAgent yes
#      ForwardX11 yes
#      ForwardX11Trusted yes
#      User ec2-user
#      IdentityFile ~/.ssh/identity.pem

EOF
    chmod 600 ~/.ssh/config
fi
