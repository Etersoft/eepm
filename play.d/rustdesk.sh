#!/bin/sh

BASEPKGNAME=rustdesk
SUPPORTEDARCHES="x86_64 armhf"
VERSION="$2"
if [ "$VERSION" = "nightly" ] ; then
    SUPPORTEDARCHES="x86_64 aarch64"
fi
DESCRIPTION="RustDesk — Display and control your PC and Android devices"
PRODUCTALT="stable nightly"

. $(dirname $0)/common.sh

arch=$(epm print info -a)
pkgtype=deb

if [ "$PKGNAME" = "$BASEPKGNAME-nightly" ] ; then
    PKGNAME=rustdesk
    # https://github.com/rustdesk/rustdesk/releases/download/nightly/rustdesk-1.2.0-aarch64.deb
    MASK="nightly/$PKGNAME-$VERSION-$arch.$pkgtype"
else
    PKGNAME=rustdesk
    #rustdesk-1.1.9-raspberry-armhf.deb
    #rustdesk-1.1.9.deb
    [ "$VERSION" = "*" ] && VERSION="[0-9].[0-9].[0-9]"
    [ "$arch" = "armhf" ] && VERSION="$VERSION-raspberry-armhf"
    MASK="[0-9]/$PKGNAME-$VERSION.$pkgtype"
fi

PKGURL=$(epm tool eget --list --latest https://github.com/rustdesk/rustdesk/releases "$MASK") || fatal "Can't get package URL"
epm install $PKGURL || exit

cat <<EOF

Note: run
# serv rustdesk on
to enable needed rustdesk system service (daemon)
EOF
