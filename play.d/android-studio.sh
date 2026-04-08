#!/bin/sh

PKGNAME=android-studio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The official Android IDE'
URL="https://developer.android.com/studio"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest "https://developer.android.com/studio" "android-studio-*-linux.tar.gz")"
else
    # version-specific install: scrape page for matching version
    PKGURL="$(eget --list --latest "https://developer.android.com/studio" "android-studio-*-linux.tar.gz" | grep "/ide-zips/$VERSION/")"
    [ -n "$PKGURL" ] || fatal "Can't find android-studio $VERSION on developer.android.com"
fi

install_pack_pkgurl
