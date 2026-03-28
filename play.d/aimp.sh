#!/bin/sh

PKGNAME=aimp
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="AIMP native audio player (beta) from the official site"
URL="https://aimp.ru/?do=download&os=desktop"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"

case $pkgtype in
    deb)
        PKGURL="https://aimp.ru/?do=download.file&id=30"
        ;;
    *)
        PKGURL="https://aimp.ru/?do=download.file&id=29"
        ;;
esac

install_pkgurl
