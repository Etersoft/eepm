#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=teams

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Install Microsoft Teams for Linux from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

# rpm and deb contains the same binaries
#https://packages.microsoft.com/yumrepos/ms-teams/teams-1.3.00.25560-1.x86_64.rpm

# epm uses eget to download * names
epm install "https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/$(epm print constructname teams "*" amd64 deb)"
