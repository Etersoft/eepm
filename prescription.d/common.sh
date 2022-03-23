#!/bin/sh

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
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
