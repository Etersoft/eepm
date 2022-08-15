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

epm play chromium-codecs-ffmpeg-extra || fatal

if [ "$BRANCH" = "stable" ] ; then

# https://get.geo.opera.com/pub/${pkgname}/desktop/${pkgver}/linux/${pkgname}-stable_${pkgver}_amd64.deb
# fast hack for download from CDN
URL="https://download5.operacdn.com/pub/opera/desktop"
if ! check_url_is_accessible $URL ; then
    URL="https://download3.operacdn.com/pub/opera/desktop"
    check_url_is_accessible $URL || fatal "Can't access to Opera CDN site $URL"
fi

PKGBASEURL="$(eget --list --latest $URL/*)"linux
PKGURL="$(epm tool eget --list --latest $PKGBASEURL "$(epm print constructname $PKGNAME "*" $arch deb)")" || fatal #"
epm install "$PKGURL" || fatal
exit

else

[ "$($DISTRVENDOR -s)" = "alt" ] && repack='--repack' || repack=''
epm install $repack https://rpm.opera.com/rpm/opera_$BRANCH-*-linux-release-x64-signed.rpm

fi
