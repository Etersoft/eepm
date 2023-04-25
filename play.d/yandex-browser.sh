#!/bin/sh

BASEPKGNAME=yandex-browser
SUPPORTEDARCHES="x86_64"
PRODUCTALT="stable beta"
VERSION="$2"
DESCRIPTION="Yandex browser from the official site"
TIPS="Run 'epm play yandex-browser=beta' to install beta version of the browser."

. $(dirname $0)/common.sh

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yandex-browser-beta

URL="https://repo.yandex.ru/yandex-browser"

if [ "$(epm print info -s)" = "alt" ] || [ "$(epm print info -p)" != "rpm" ] ; then
    epm install "$URL/deb/pool/main/y/$PKGNAME/$(epm print constructname $PKGNAME "$VERSION*" amd64 deb)" || exit
else
    # https://repo.yandex.ru/yandex-browser/rpm/stable/x86_64/yandex-browser-stable-23.1.1.1114-1.x86_64.rpm
    epm install "$URL/rpm/stable/x86_64/$(epm print constructname $PKGNAME "$VERSION*" x86_64 rpm)" || exit
fi

UPDATEFFMPEG=$(epm ql $PKGNAME | grep update-ffmpeg) || fatal
epm pack --install $PKGNAME-codecs-ffmpeg-extra $UPDATEFFMPEG
