#!/bin/sh

PKGNAME=net.downloadhelper.coapp
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Video DownloadHelper Companion App (obsoleted)"
URL="https://www.downloadhelper.net/install-coapp"

. $(dirname $0)/common.sh

mask="$PKGNAME-${VERSION}_amd64.deb"

PKGURL=$(eget --list --latest https://github.com/aclap-dev/vdhcoapp/releases/ "$mask") || fatal "Can't get package URL"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL"
