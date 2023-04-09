#!/bin/sh

PKGNAME=aimp
SUPPORTEDARCHES="x86_64"
DESCRIPTION="AIMP (Wine based audio player) from the official site"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

if ! is_command wine ; then
    epm play wine || fatal
fi

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

case $pkgtype in
    deb)
        epm install "https://www.aimp.ru/?do=download.file&id=26"
        ;;
    rpm)
        epm $repack install "https://www.aimp.ru/?do=download.file&id=32"
        ;;
    *)
        fatal "Unsupported $pkgtype"
        ;;
esac

