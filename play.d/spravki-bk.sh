#!/bin/sh

PKGNAME=spravki-bk
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Система подготовки отчетности «Справки БК»"
URL="http://www.kremlin.ru/structure/additional/12/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Get download URL for Astra Linux version from kremlin.ru
PKGURL=$(eget -q -O- http://www.kremlin.ru/structure/additional/12/ | grep -B1 "для Astra Linux" | grep -o 'href="[^"]*"' | sed 's/href="//;s/"//' | head -n 2 | tail -n 1)

install_pack_pkgurl
