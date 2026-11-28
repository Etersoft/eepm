#!/bin/sh

PKGNAME=r7draw-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="R7 Graphics (R7-Grafika) diagram editor from the official site"
URL="https://support.r7-office.ru/download/grafika-desktop/"
TIPS="R7 Graphics asks for a license file on the first run (Choose license); without it the application closes."

. $(dirname $0)/common.sh

case $(epm print info -p) in
    rpm)
        # https://download.r7-office.ru/r7graph/r7draw-desktop-x86_64-26.2.1.rpm
        file="r7draw-desktop-x86_64-${VERSION}.rpm"
        # skip .alt-linux.rpm when looking for the latest
        [ "$VERSION" = "*" ] && file="r7draw-desktop-x86_64-*[0-9].rpm"
        ;;
    *)
        # https://download.r7-office.ru/r7graph/r7draw-desktop-amd64-26.2.1.deb
        file="r7draw-desktop-amd64-${VERSION}.deb"
        ;;
esac

case $(epm print info -s) in
    alt)
        # https://download.r7-office.ru/r7graph/r7draw-desktop-x86_64-26.2.1.alt-linux.rpm
        file="r7draw-desktop-x86_64-${VERSION}.alt-linux.rpm"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest "$URL" "$file")" || fatal "Can't get package URL"
else
    PKGURL="https://download.r7-office.ru/r7graph/$file"
fi

install_pkgurl || exit

echo
echo "$TIPS"
