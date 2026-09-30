#!/bin/sh

PKGNAME=trivalent-qt6-ui
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Qt 6 native file dialog integration for Trivalent"
URL="https://github.com/secureblue/Trivalent"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
REPOURL="https://repo.secureblue.dev"

[ "$VERSION" = "*" ] && VERSION='[0-9.]*'
filename="$(get_rpm_repo_latest_file "$REPOURL" "Packages/$PKGNAME-$VERSION-[0-9]*\.$arch\.rpm")"
[ -n "$filename" ] || fatal "Can't find Trivalent Qt 6 integration $VERSION for $arch in $REPOURL"
PKGURL="$REPOURL/$filename"

install_pkgurl
