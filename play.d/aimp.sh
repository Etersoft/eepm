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

