#!/bin/sh

PKGNAME=rustdesk
SUPPORTEDARCHES="x86_64 armhf"
DESCRIPTION="RustDesk — Display and control your PC and Android devices"
PRODUCTALT="stable nightly"

. $(dirname $0)/common.sh

arch=$(epm print info -a)
pkgtype=deb

BRANCH=stable
if [ "$2" = "nightly" ] ; then
    BRANCH=nightly
    SUPPORTEDARCHES="x86_64 aarch64"
    MASK="$PKGNAME-*$arch*.$pkgtype"
    # https://github.com/rustdesk/rustdesk/releases/download/nightly/rustdesk-1.2.0-aarch64-unknown-linux-gnu-ubuntu-18.04.deb
    URL=$(epm tool eget --list --latest https://github.com/rustdesk/rustdesk/releases "$MASK") || fatal "Can't get package URL"
else
    [ "$arch" = "armhf" ] && arch="raspberry-armhf" || arch="[0-9].[0-9].[0-9]"
    MASK="$PKGNAME-$arch.$pkgtype"
    #rustdesk-1.1.9-raspberry-armhf.deb
    #rustdesk-1.1.9.deb
fi

URL=$(epm tool eget --list --latest https://github.com/rustdesk/rustdesk/releases "$MASK") || fatal "Can't get package URL"
epm install $URL || exit

cat <<EOF

Note: run
# serv rustdesk on
to enable needed rustdesk system service (daemon)
EOF
