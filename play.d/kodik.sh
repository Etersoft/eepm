#!/bin/sh

PKGNAME=Kodik
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Kodik — это первая российская AI-IDE, которая действует как второй разработчик"
URL="https://kodik.ru"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(eget -O- "$URL/download" | grep -o 'https://api\.vibekodik\.ru/v1/storage/[0-9][0-9]*/download' | tail -n1)"

install_pkgurl
