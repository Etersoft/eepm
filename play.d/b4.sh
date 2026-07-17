#!/bin/sh
PKGNAME=b4
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Network packet processor with a friendly UI for circumventing Deep Packet Inspection (DPI) systems"
URL="https://github.com/DanielLavrushin/b4"

. $(dirname $0)/common.sh

arch=$(epm print info --debian-arch)

if [ "$VERSION" = "*" ] ; then
	VERSION="$(get_github_tag https://github.com/DanielLavrushin/b4)"
fi

PKGURL="https://github.com/DanielLavrushin/b4/releases/download/v$VERSION/b4-linux-$arch.tar.gz"

install_pack_pkgurl $VERSION
