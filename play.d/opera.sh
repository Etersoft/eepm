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
    pkgname="${PKGNAME/-/_}"

    # they put all branch here (rpm only): https://rpm.opera.com/rpm/
    PKGURL="https://rpm.opera.com/rpm/$pkgname-$VERSION-linux-release-x64-signed.rpm"
else
    PKGURL="https://deb.opera.com/opera-developer/pool/non-free/o/$PKGNAME/$(epm print constructname $PKGNAME "$VERSION" $arch deb)"
fi

install_pkgurl
