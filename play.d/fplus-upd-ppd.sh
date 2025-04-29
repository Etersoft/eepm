#!/bin/sh

PKGNAME=fplus-upd-ppd
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="fplus drivers from the official site"
URL="https://fplustech.ru/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

SOURL=$(eget --list --latest "https://fplustech.ru/product/mnogofunktsionalnoe-ustroystvo-fplus-mc241adfw/" "Драйвер для Linux.zip" | head -n 1)

PKGURL="${SOURL}%20для%20Linux.zip"

install_pack_pkgurl

echo "Note: run
# serv cups restart
to enable new printer model in cups
"