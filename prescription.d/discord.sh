#!/bin/sh -x

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=discord

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Install Discord from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# FIXME: improve eget to support ? not ask mask (detect by =?)
#PKG=/tmp/discord.deb
#$EGET -O $PKG "https://discord.com/api/download?platform=linux&format=deb"
PKG="https://dl.discordapp.net/apps/linux/0.0.12/discord-0.0.12.deb"

epm install "$PKG"
