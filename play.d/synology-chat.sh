#!/bin/sh

PKGNAME=synology-chat
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Synology Chat Client from the official site'

. $(dirname $0)/common.sh

urldir="$(epm tool eget --list https://archive.synology.com/download/Utility/ChatClient '/[0-9]*' | head -n1)"
[ -n "$urldir" ] || exit

# use temp dir
PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal

# fix spaces in the package name
epm tool eget -O $PKGNAME.deb "$urldir/Synology*.deb"

epm install $PKGNAME.deb

