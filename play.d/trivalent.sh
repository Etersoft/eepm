#!/bin/sh

PKGNAME=trivalent
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Security-focused Chromium-based browser from the official secureblue repository"
URL="https://github.com/secureblue/Trivalent"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
REPOURL="https://repo.secureblue.dev"

[ "$VERSION" = "*" ] && VERSION='[0-9.]*'
filename="$(get_rpm_repo_latest_file "$REPOURL" "Packages/trivalent-$VERSION-[0-9]*\.$arch\.rpm")"
[ -n "$filename" ] || fatal "Can't find Trivalent $VERSION for $arch in $REPOURL"
PKGURL="$REPOURL/$filename"

install_pkgurl
