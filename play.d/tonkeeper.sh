#!/bin/sh

PKGNAME=Tonkeeper
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Tonkeeper desktop from the official site"
URL="https://tonkeeper.com/desktop"

. $(dirname $0)/common.sh

arch="$(epm print info --distro-arch)"
pkgtype="$(epm print info -p)"

case "$pkgtype" in
    rpm)
        [ "$VERSION" = "*" ] && VERSION="[0-9]*" || VERSION="$VERSION-1"
        ;;
    *)
        override_pkgname "tonkeeper"
        pkgtype="deb"
        ;;
esac

# https://github.com/tonkeeper/tonkeeper-web/releases/download/v3.7.1/tonkeeper_3.7.1_amd64.deb
# https://github.com/tonkeeper/tonkeeper-web/releases/download/v3.7.1/Tonkeeper-3.7.1-1.x86_64.rpm

PKGURL=$(eget --list --latest https://github.com/tonkeeper/tonkeeper-web/releases $(epm print constructname $PKGNAME "$VERSION" $arch $pkgtype)) || fatal "Can't get package URL"

install_pkgurl
