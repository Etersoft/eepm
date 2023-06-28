#!/bin/sh

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    echo "$*" >&2
}

is_root()
{
	local EFFUID="$(id -u)"
	[ "$EFFUID" = "0" ]
}

assure_root()
{
	is_root || fatal "run me only under root"
}


if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

if [ "$1" = "--installed" ] ; then
    epm installed $PKGNAME
    exit
fi


if [ -n "$DESCRIPTION" ] ; then
    [ "$1" != "--run" ] && echo "$DESCRIPTION" && exit
fi
