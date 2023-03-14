#!/bin/sh

PKGNAME=liteide
SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION="LiteIDE is a simple, open source, cross-platform Go IDE. From the official site"

. $(dirname $0)/common.sh

archbit="$(epm print info -b)"

PKGURL=$(epm tool eget --list --latest https://github.com/visualfc/liteide/releases "liteidex*.linux$archbit-qt5*-system.tar.gz") #"
[ -n "$PKGURL" ] || fatal "Can't get package URL"

# cd to tmp dir
PKGDIR=$(mktemp -d)
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

name="$(basename "$PKGURL" | sed -e 's|liteidex|liteide-|')"
epm tool eget -O "$name" "$PKGURL"

epm install --repack "$name"
