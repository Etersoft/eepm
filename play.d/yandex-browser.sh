#!/bin/sh

BASEPKGNAME=yandex-browser
SUPPORTEDARCHES="x86_64"
PRODUCTALT="stable beta corporate"
VERSION="$2"
DESCRIPTION="Yandex browser from the official site"
URL="https://browser.yandex.ru/"
TIPS="Run 'epm play yandex-browser=beta' to install beta version of the browser."

. $(dirname $0)/common.sh

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yandex-browser-beta

URL="https://repo.yandex.ru/yandex-browser"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

if [ "$(epm print info -p)" = "rpm" ] ; then
    # https://repo.yandex.ru/yandex-browser/rpm/stable/x86_64/yandex-browser-stable-23.1.1.1114-1.x86_64.rpm
    [ "$BRANCH" = "corporate" ] && BRANCH="stable"
    PKGURL="$URL/rpm/$BRANCH/x86_64/$(epm print constructname $PKGNAME "$VERSION*" x86_64 rpm)" || fatal "Can't get package URL"
    epm install --repack "$PKGURL" || exit
else
    # https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/yandex-browser-beta_23.5.4.682-1_amd64.deb
    PKGURL="$URL/deb/pool/main/y/$PKGNAME/$(epm print constructname $PKGNAME "$VERSION*" amd64 deb)"
    epm install "$PKGURL" || exit
fi

# TODO: use needed version
if [ "$(epm print info -s)" = "alt" ] ; then
    epm install ffmpeg-plugin-browser
    exit
fi

UPDATEFFMPEG=$(epm ql $PKGNAME | grep update-ffmpeg) || fatal
epm pack --install $PKGNAME-codecs-ffmpeg-extra $UPDATEFFMPEG
