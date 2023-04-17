#!/bin/sh

DESCRIPTION="Panasonic Scanner Driver for Linux from the official site"

PKGNAME=sane-panakvs

SUPPORTEDARCHES="x86_64"

. $(dirname $0)/common.sh

VERSION=1.7.0

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        file="libsane-panakvs-$VERSION-x86_64.tar.gz"
        ;;
# we don't support old arches
#    x86)
#        file="libsane-panakvs-$VERSION-i686.tar.gz"
#        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

PKGURL="https://www.psn-web.net/cs-im/Japan/Scanner/cojp/data_cmns/linux/$file"

epm pack --install $PKGNAME "$PKGURL"
