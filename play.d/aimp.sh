#!/bin/sh

PKGNAME=aimp
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="AIMP (Wine based audio player) from the official site"
URL="https://www.aimp.ru/?do=download&os=linux"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

if ! is_command wine ; then
    epm play wine || fatal
fi

warn_version_is_not_supported

case $pkgtype in
    deb)
        PKGURL="https://www.aimp.ru/?do=download.file&id=26"
        ;;
    *)
        PKGURL="https://www.aimp.ru/?do=download.file&id=32"
        ;;
esac

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm $repack install "$PKGURL"
