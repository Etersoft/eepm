#!/bin/sh

PKGNAME=opera-gx-stable
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Opera GX gaming browser from the official site"
URL="https://www.opera.com/gx"

. $(dirname $0)/common.sh

arch="amd64"

# will use libffmpeg.so (via config added in repack)
epm install --skip-installed ffmpeg-plugin-browser || epm play nwjs-ffmpeg-prebuilt

warn_version_is_not_supported

if [ "$(epm print info -p)" = "rpm" ] ; then
    pkgname=$(echo "$PKGNAME" | tr - _)
    PKGURL="https://rpm.opera.com/rpm/$pkgname-$VERSION-linux-release-x64-signed.rpm"
else
    PKGURL="https://deb.opera.com/opera-developer/pool/non-free/o/$PKGNAME/$(epm print constructname $PKGNAME "$VERSION" $arch deb)"
fi

install_pkgurl
