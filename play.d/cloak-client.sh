#!/bin/sh

PKGNAME=cloak-client
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Cloak client - a censorship circumvention tool to evade deep packet inspection"
URL="https://github.com/cbeuw/Cloak"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        goarch=amd64
        ;;
    aarch64)
        goarch=arm64
        ;;
    armhf)
        goarch=arm
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag https://github.com/cbeuw/Cloak/)"
fi

PKGURL="https://github.com/cbeuw/Cloak/releases/download/v$VERSION/ck-client-linux-$goarch-v$VERSION"

install_pack_pkgurl $VERSION
