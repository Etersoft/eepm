#!/bin/sh

SUDO="sudo --"
#sudofunc

sudofunc()
{
    echo "arg1: $1"
    echo "arg2: $2"
    echo "arg3: $3"
    echo "arg4: $4"
}

# fake
showcmd()
{
	echo "$@"
}

# Print command line and run command line with SUDO
sudocmd()
{
	showcmd "$SUDO $@"
#FIXME
	$SUDO "$@"
}


sudocmd "ls -l" "-a -a"

sudocmd ls -l
