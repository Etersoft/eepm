#!/bin/sh

PKGNAME=rustdesk
SUPPORTEDARCHES="x86_64 armhf"
DESCRIPTION="RustTDesk — Display and control your PC and Android devices"

. $(dirname $0)/common.sh

arch=$($DISTRVENDOR -a)
[ "$arch" = "armhf" ] || arch="[0-9]"
pkgtype=deb

#rustdesk-1.1.9-raspberry-armhf.deb
#rustdesk-1.1.9.deb
URL=$(epm tool eget --list --latest https://github.com/rustdesk/rustdesk/releases "$PKGNAME-*$arch.$pkgtype") || fatal "Can't get package URL"
epm install $URL

cat <<EOF

Note: run
# serv rustdesk on
to enable needed rustdesk system service (daemon)
EOF
