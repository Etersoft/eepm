#!/bin/sh

PKGNAME=softmaker-freeoffice-2021
SUPPORTEDARCHES="x86_64"
DESCRIPTION="SoftMaker Free Office from the official site"
TIPS="Run epm play freeoffice=<version> to install some specific version"

. $(dirname $0)/common.sh

pkgver="*"
[ -n "$2" ] && pkgver="$2"

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        file="softmaker-freeoffice-$pkgver*.x86_64.rpm"
        ;;
    *)
        file="softmaker-freeoffice-$pkgver*_amd64.deb"
        ;;
esac

PKGURL="$(epm tool eget --list --latest https://www.freeoffice.com/ru/download/applications $file)" || fatal "Can't get package URL"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL"
