#!/bin/sh

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}



# compatibility layer

# check if <arg> is a real command
is_command()
{
    epm tool which "$1" >/dev/null
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
    local i
    [ -n "$RETURNTARNAME" ] || fatal "RETURNTARNAME is empty"
    rm -f $RETURNTARNAME
    for i in $* ; do
        realpath $i >>$RETURNTARNAME || fatal "Can't save tar name $i to file $RETURNTARNAME"
    done
    exit 0
}

install_file()
{
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")" || return
    cp "$src" "$dest" || return
}


[ -n "$PRODUCT" ] || PRODUCT="$(basename $0 .sh)"
