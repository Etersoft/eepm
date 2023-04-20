#!/bin/sh

PKGNAME=net.downloadhelper.coapp
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Video DownloadHelper Companion App"
URL="https://www.downloadhelper.net/install-coapp"

. $(dirname $0)/common.sh

mask="$PKGNAME-*_amd64.deb"

PKGURL=$(eget --list --latest https://github.com/mi-g/vdhcoapp/releases/ $mask) || fatal "Can't get package URL"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL"
