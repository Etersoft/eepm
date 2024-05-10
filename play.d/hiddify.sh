#!/bin/sh
PKGNAME=hiddify
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Кроссплатформенный прокси-клиент на основе ядра Sing-box"
URL="https://github.com/hiddify/hiddify-next"

. $(dirname $0)/common.sh

if ! is_glibc_enough 2.32 ; then
	fatal "Версия glibc слишком старая, обновите свою систему"
fi

if [ "$VERSION" = "*" ] ; then
	VERSION="$(eget --get-real-url -O- https://github.com/hiddify/hiddify-next/releases/latest | awk -F '/' '{print $(NF)}' | awk -F 'v' '{print $2}')"
fi

PKGURL="https://github.com/hiddify/hiddify-next/releases/download/v$VERSION/Hiddify-Debian-x64.deb"

install_pkgurl
