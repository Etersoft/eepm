#!/bin/sh

DESCRIPTION="Yandex browser from the official site"
TIPS="Run 'epm play yandex-browser=beta' to install beta version of the browser."

PRODUCTALT="stable beta"

BRANCH=stable
if [ "$2" = "beta" ] || epm installed yandex-browser-beta ; then
    BRANCH=beta
fi

PKGNAME=yandex-browser-$BRANCH
SUPPORTEDARCHES="x86_64"

. $(dirname $0)/common.sh

is_repacked_package || exit 0

# See also https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=yandex-browser-beta

URL="https://repo.yandex.ru/yandex-browser"

if [ "$(epm print info -s)" = "alt" ] || [ "$(epm print info -p)" != "rpm" ] ; then
    # epm uses eget to download * names
    epm install "$URL/deb/pool/main/y/$PKGNAME/$(epm print constructname $PKGNAME "*" amd64 deb)" || exit
else
    # https://repo.yandex.ru/yandex-browser/rpm/stable/x86_64/yandex-browser-stable-23.1.1.1114-1.x86_64.rpm
    epm install "$URL/rpm/stable/x86_64/$(epm print constructname $PKGNAME "*" x86_64 rpm)" || exit
fi

UPDATEFFMPEG=$(epm ql $PKGNAME | grep update-ffmpeg) || fatal
epm pack --install $PKGNAME-codecs-ffmpeg-extra $UPDATEFFMPEG
