#!/bin/sh
PKGNAME=hiddify
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Кроссплатформенный прокси-клиент на основе ядра Sing-box"
URL="https://github.com/hiddify/hiddify-next"

. $(dirname $0)/common.sh

if ! is_glibc_enough 2.34 ; then
	fatal "Версия glibc слишком старая, обновите свою систему"
fi

if [ "$VERSION" = "*" ] ; then
	VERSION="$(get_github_tag https://github.com/hiddify/hiddify-next/ prerelease)"
fi

PKGURL="https://github.com/hiddify/hiddify-next/releases/download/v$VERSION/Hiddify-Debian-x64.deb"

install_pkgurl
