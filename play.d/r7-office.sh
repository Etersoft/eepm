#!/bin/sh

PKGNAME=r7-office
SKIPREPACK=1
SUPPORTEDARCHES="x86_64"
DESCRIPTION="R7 Office for Linux from the official site"
URL="https://r7-office.ru/"

. $(dirname $0)/common.sh

URLBASE="https://r7-office.ru/download_editor"

#[ "$VERSION" = "*" ]

# $ eget -U --list "https://r7-office.ru/download_editor" "*.rpm"
# $ eget -U --list "https://r7-office.ru/download_editor" "*.deb"

case $(epm print info -e) in
    AstraLinux*|Debian/*)
        mask="astra/*.deb"
        ;;
    Ubuntu/*)
        mask="ubuntu/*.deb"
        ;;
    RedOS/*|AlterOS/*)
        mask="centos/*.rpm"
        ;;
    ROSA/7.9)
        mask="rosa/cobalt/$PKGNAME-*.rpm"
        ;;
    ROSA/*)
        mask="rosa/$PKGNAME-*.rpm"
        ;;
    ALTLinux/*)
        mask="altlinux/*.rpm"
        ;;
    *)
        fatal "Unsupported distro $(epm print info -e). Ask application vendor for a support."
        ;;
esac

PKGURL="$(epm tool eget --list --latest -U  "$URLBASE" "$mask")"

# install with scripts (need for install icons and associations)
# see /etc/eepm/pkgallowscripts.list
# TODO: pack it into the package
epm install "$PKGURL"
