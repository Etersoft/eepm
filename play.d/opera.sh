#!/bin/sh

DESCRIPTION="Opera browser from the official site"

PRODUCTALT="stable beta developer"

BRANCH=stable
if [ "$2" = "beta" ] || epm installed opera-beta ; then
    BRANCH=beta
fi
if [ "$2" = "developer" ] || epm installed opera-developer ; then
    BRANCH=developer
fi
PKGNAME=opera-$BRANCH

SUPPORTEDARCHES="x86_64"

. $(dirname $0)/common.sh

arch="amd64"

# will use libffmpeg.so (via config added in repack)
epm install --skip-installed ffmpeg-plugin-browser || epm install --skip-installed chromium-codecs-ffmpeg-extra || epm play chromium-codecs-ffmpeg-extra

if [ "$(epm print info -p)" = "rpm" ] ; then
    # they put all branch here (rpm only): https://rpm.opera.com/rpm/
    [ "$(epm print info -s)" = "alt" ] && repack='--repack' || repack=''
    PKGURL="https://rpm.opera.com/rpm/opera_$BRANCH-*-linux-release-x64-signed.rpm"
    epm install $repack $PKGURL
    exit
fi

PKGURL="https://deb.opera.com/opera-developer/pool/non-free/o/opera-$BRANCH/$(epm print constructname $PKGNAME "*" $arch deb)"
epm install "$PKGURL"
