#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=microsoft-edge-dev

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Microsoft Edge browser (dev) from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# epm uses eget to download * names
epm install "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-dev/microsoft-edge-*_amd64.deb"
