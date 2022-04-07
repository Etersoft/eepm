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

if [ "$1" = "--description" ] ; then
     echo "$DESCRIPTION"
     exit
fi


[ "$1" != "--run" ] && [ "$1" != "--update" ] && fatal "Unknown command $1"

if [ "$1" = "--update" ] ; then
     if ! epm installed $PKGNAME ; then
         echo "Skipping update of $PKGNAME (package is not installed)"
         exit
     fi
fi

