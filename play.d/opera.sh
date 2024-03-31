#!/bin/sh

BASEPKGNAME=opera
SUPPORTEDARCHES="x86_64"
PRODUCTALT="stable beta developer"
VERSION="$2"
DESCRIPTION="Opera browser from the official site"
URL="https://opera.com"

. $(dirname $0)/common.sh

arch="amd64"

# will use libffmpeg.so (via config added in repack)
epm install --skip-installed ffmpeg-plugin-browser || epm install --skip-installed chromium-codecs-ffmpeg-extra || epm play chromium-codecs-ffmpeg-extra

if [ "$(epm print info -p)" = "rpm" ] ; then
    override_pkgname "${PKGNAME/-/_}"

    # they put all branch here (rpm only): https://rpm.opera.com/rpm/
    [ "$(epm print info -s)" = "alt" ] && repack='--repack' || repack=''
    PKGURL="https://rpm.opera.com/rpm/$PKGNAME-$VERSION-linux-release-x64-signed.rpm"
    epm install $repack "$PKGURL"
    exit
fi

PKGURL="https://deb.opera.com/opera-developer/pool/non-free/o/$PKGNAME/$(epm print constructname $PKGNAME "$VERSION" $arch deb)"
epm install "$PKGURL"
