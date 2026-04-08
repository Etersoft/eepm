#!/bin/sh

PKGNAME=android-studio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The official Android IDE'
URL="https://developer.android.com/studio"

. $(dirname $0)/common.sh

PKGURL="$(eget --list --latest "https://developer.android.com/studio" "android-studio-*-linux.tar.gz")"
[ -n "$PKGURL" ] || fatal "Can't get android-studio download URL from developer.android.com"

# check that the scraped URL matches requested version; old versions are removed from the page
if [ "$VERSION" != "*" ] && ! echo "$PKGURL" | grep -q "/ide-zips/$VERSION/" ; then
    info "Note: requested android-studio version $VERSION is no longer available, using latest"
fi

install_pack_pkgurl
