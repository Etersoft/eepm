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

is_abs_path()
{
    echo "$1" | grep -q "^/"
}

is_url()
{
    echo "$1" | grep -q "^[filehtps]*:/"
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

__handle_tarname()
{
    # TODO: we don't know PKGNAME here
    PKGNAME=

    if [ -n "$EEPM_INTERNAL_PKGNAME" ] ; then
        # it is ok
        [ "$EEPM_INTERNAL_PKGNAME" = "$PKGNAME" ] && continue
        # PKGNAME was changed in play.d script after common.sh include
        echo "Packing as $PKGNAME (not $EEPM_INTERNAL_PKGNAME as it said before) ..."
    else
        # it is possible direct call, not from epm play
        echo "Packing as $PKGNAME package ..."
    fi

    export EEPM_INTERNAL_PKGNAME="$PKGNAME"
}


return_tar()
{
    local i
    [ -n "$RETURNTARNAME" ] || fatal "RETURNTARNAME is empty"
    rm -f $RETURNTARNAME
    for i in $* ; do
        #__handle_tarname $i
        realpath $i >>$RETURNTARNAME || fatal "Can't save tar name $i to file $RETURNTARNAME"
    done
    exit 0
}

# really like install -D src dst
install_file()
{
    local src="$1"
    local dest="$2"

    if is_abs_path "$dest" ; then
        dest=".$dest"
    fi
    mkdir -p "$(dirname "$dest")" || return

    if is_url "$src" ; then
        epm tool eget -O "$dest" "$src" || fatal "Can't download $src to install to $dest"
    else
        cp "$src" "$dest" || return
    fi
    chmod 0644 "$dest"
}

# Create target file from file
# Usage: echo "text" | create_file file
create_file()
{
    local t="$1"
    install_file /dev/stdin $t
}


# set PRODUCT by pack.d script name
[ -n "$PRODUCT" ] || PRODUCT="$(basename $0 .sh)"
