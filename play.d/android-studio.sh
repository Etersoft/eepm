#!/bin/sh

PKGNAME=android-studio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The official Android IDE'
URL="https://developer.android.com/studio"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest "https://developer.android.com/studio" "$PKGNAME-$VERSION-linux.tar.gz")"
else
    PKGURL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/$VERSION/$PKGNAME-$VERSION-linux.tar.gz"
fi

install_pkgurl

