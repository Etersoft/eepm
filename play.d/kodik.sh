#!/bin/sh

PKGNAME=Kodik
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Kodik — это первая российская AI-IDE, которая действует как второй разработчик"
URL="https://vibekodik.ru"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(eget -O- https://vibekodik.ru/download | grep -oP 'https://[^"]+\.AppImage[^"]*' | head -n1 | sed 's/&amp;/\&/g')"

install_pkgurl
