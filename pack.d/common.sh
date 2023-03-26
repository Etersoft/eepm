#!/bin/sh

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

# compatibility layer
# add realpath if missed
if ! which realpath 2>/dev/null >/dev/null ; then
realpath()
{
    [ -n "$*" ] || return
    readlink -f "$@"
}
fi

# add subst if missed
if ! which subst 2>/dev/null >/dev/null ; then
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

