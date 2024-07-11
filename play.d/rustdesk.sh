#!/bin/sh

PKGNAME=rustdesk
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="RustDesk — Display and control your PC and Android devices"
URL="https://github.com/rustdesk/rustdesk/"

. $(dirname $0)/common.sh

arch=$(epm print info -a)
pkgtype=deb

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/rustdesk/rustdesk/" "$PKGNAME-.$VERSION-$arch.$pkgtype")
else
    PKGURL="https://github.com/rustdesk/rustdesk/releases/download/$VERSION/$PKGNAME-$VERSION-$arch.$pkgtype"
fi

install_pkgurl

cat <<EOF

Note: run
# serv rustdesk on
to enable needed rustdesk system service (daemon)
EOF
