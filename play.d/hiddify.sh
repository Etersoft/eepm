#!/bin/sh
PKGNAME=hiddify
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Кроссплатформенный прокси-клиент на основе ядра Sing-box"
URL="https://github.com/hiddify/hiddify-app"

. $(dirname $0)/common.sh

if ! is_glibc_enough 2.34 ; then
	fatal "Версия glibc слишком старая, обновите свою систему"
fi

PKGURL="$(get_github_url "$URL" "Hiddify-Debian-x64.deb")"

install_pkgurl
