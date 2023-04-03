#!/bin/sh

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}



# compatibility layer
# print a path to the command if exists in $PATH
if which which 2>/dev/null >/dev/null ; then
    # the best case if we have which command (other ways needs checking)
    # TODO: don't use which at all, it is binary, not builtin shell command
print_command_path()
{
    which -- "$1" 2>/dev/null
}
elif type -a type 2>/dev/null >/dev/null ; then
print_command_path()
{
    type -fpP -- "$1" 2>/dev/null
}
else
print_command_path()
{
    type "$1" 2>/dev/null | sed -e 's|.* /|/|'
}
fi

# check if <arg> is a real command
is_command()
{
    print_command_path "$1" >/dev/null
}

# compatibility layer

# add realpath if missed
if ! is_command realpath ; then
realpath()
{
    [ -n "$*" ] || return
    readlink -f "$@"
}
fi

# add subst if missed
if ! is_command subst ; then
subst()
{
    sed -i -e "$@"
}
fi



erc()
{
    epm tool erc "$@"
}

is_dir_empty()
{
    [ -z "$(ls -A "$1")" ]
}

# copied from strings
# CHECKME: the same like estrlist has ?
# Note: used grep -E! write '[0-9]+(first|two)', not '[0-9]\+...'
rhas()
{
    echo "$1" | grep -E -q -- "$2"
}

has_space()
{
    [ "${1/ /}" != "$1" ]
}

has_wildcard()
{
    [ "${1/\*/}" != "$1" ]
}


return_tar()
{
    [ -n "$RETURNTARNAME" ] || fatal "RETURNTARNAME is empty"
    echo $1 >$RETURNTARNAME || fatal "Can't save tar name $1 to file $RETURNTARNAME"
}

