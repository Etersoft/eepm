#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=brave-browser

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Brave browser from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

arch=x86_64
pkgtype=rpm

PKG=$($EGET --list --latest https://github.com/brave/brave-browser/releases "$PKGNAME-*.$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKG"
