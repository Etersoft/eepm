#!/bin/sh

PKGNAME=synology-drive
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Synology Drive Client from the official site'

. $(dirname $0)/common.sh

urldir="$(epm tool eget --list https://archive.synology.com/download/Utility/SynologyDriveClient '/[0-9]*' | head -n1)"
[ -n "$urldir" ] || exit

epm install "$urldir/$PKGNAME*.x86_64.deb"

