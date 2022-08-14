#!/bin/sh

DESCRIPTION="Opera browser from the official site"

PKGNAME=opera-stable
SUPPORTEDARCHES="x86_64"

. $(dirname $0)/common.sh

arch="amd64"

epm play chromium-codecs-ffmpeg-extra || fatal

# https://get.geo.opera.com/pub/${pkgname}/desktop/${pkgver}/linux/${pkgname}-stable_${pkgver}_amd64.deb
# fast hack for download from CDN
URL="https://download5.operacdn.com/pub/opera/desktop"
check_url_is_accessible $URL || URL="https://download3.operacdn.com/pub/opera/desktop"
check_url_is_accessible $URL || fatal "Can't access to Opera CDN site $URL"

PKGBASEURL="$(eget --list --latest $URL/*)"linux
PKGURL="$(epm tool eget --list --latest $PKGBASEURL "$(epm print constructname $PKGNAME "*" $arch deb)")" || fatal
epm install "$PKGURL" || fatal
