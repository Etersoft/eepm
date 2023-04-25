#!/bin/sh

PKGNAME=yaradio-yamusic
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Yandex Radio + Yandex Music - unofficial desktop application"
URL="https://github.com/dedpnd/yaradio-yamusic"

. $(dirname $0)/common.sh

arch=amd64
# https://github.com/dedpnd/yaradio-yamusic/releases/download/v1.0.6/yaradio-yamusic_1.0.6_amd64.deb
PKGURL=$(epm tool eget --list --latest https://github.com/dedpnd/yaradio-yamusic/releases "${PKGNAME}_${VERSION}_$arch.deb")

epm install $PKGURL
