#!/bin/sh
PKGNAME=torrserver
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Torrent to http. Streams media torrent files as media streams without fully downloading"
URL="https://github.com/YouROK/TorrServer"

. $(dirname $0)/common.sh

arch=$(epm print info --debian-arch)

if [ "$VERSION" = "*" ] ; then
	VERSION="$(get_github_tag https://github.com/YouROK/TorrServer)"
fi

PKGURL="https://github.com/YouROK/TorrServer/releases/download/MatriX.$VERSION/TorrServer-linux-$arch"

install_pack_pkgurl $VERSION
