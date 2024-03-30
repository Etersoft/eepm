#!/bin/sh

PKGNAME=google-chrome-stable
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="The popular and trusted web browser by Google (Stable Channel) from the official site"
URL="https://www.google.com/chrome/"

. $(dirname $0)/common.sh

_channel="stable"
repack=''

# we have workaround for their postinstall script, so always repack rpm package
[ "$(epm print info -p)" = "deb" ] || repack='--repack'

if [ "$VERSION" = "*" ] ; then
    PKGURL="https://dl.google.com/linux/direct/google-chrome-stable_current_$arch.$pkgtype"
else
    PKGURL="https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-${_channel}/google-chrome-${_channel}_${VERSION}-1_amd64.deb"
fi

epm install $repack "$PKGURL"
