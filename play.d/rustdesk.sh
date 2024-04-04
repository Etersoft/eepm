#!/bin/sh

PKGNAME=rustdesk
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="RustDesk — Display and control your PC and Android devices"
URL="https://github.com/rustdesk/rustdesk/"

. $(dirname $0)/common.sh

arch=$(epm print info -a)
pkgtype=deb

if [ "$VERSION" = "1.1.9" ] ; then
    #rustdesk-1.1.9-raspberry-armhf.deb
    #rustdesk-1.1.9.deb
    #[ "$VERSION" = "*" ] && VERSION="[0-9].[0-9].[0-9]"
    #[ "$arch" = "armhf" ] && VERSION="$VERSION-raspberry-armhf"
    MASK="$PKGNAME-$VERSION.$pkgtype"
else
    MASK="$PKGNAME-$VERSION-$arch.$pkgtype"
fi

PKGURL=$(eget --list --latest https://github.com/rustdesk/rustdesk/releases "$MASK")

# 
if [ "$VERSION" = "*" ] && echo "$PKGURL" | grep -q "nightly" ; then
    echo "Skipping nightly $PKGURL ..."
    PKGURL=$(eget --list --second-latest https://github.com/rustdesk/rustdesk/releases "$MASK")
fi

install_pkgurl

cat <<EOF

Note: run
# serv rustdesk on
to enable needed rustdesk system service (daemon)
EOF
