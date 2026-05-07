#!/bin/sh
PKGNAME=megatools
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Collection of programs for accessing Mega.nz service from a command line of your desktop or server."
URL="https://xff.cz/megatools"

. $(dirname $0)/common.sh

arch=$(epm print info -a)

if [ "$VERSION" = "*" ] ; then
	VERSION="$(eget -O- https://xff.cz/megatools/builds/builds/ | grep -oP "megatools-\K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(?=-linux-$arch\.tar\.gz)" | sort -V | tail -n1)"
fi

PKGURL="https://xff.cz/megatools/builds/builds/megatools-$VERSION-linux-$arch.tar.gz"

install_pack_pkgurl $VERSION
