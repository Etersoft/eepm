#!/bin/sh

PKGNAME=r7organizer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="R7 Office Organizer for Linux from the official site"
URL="https://r7-office.ru/downloadorganizer"

# fixme: global epm is used
case $(epm print info -p) in
    deb)
        PKGNAME="r7-organizer"
        # force latest version due broken package name
        VERSION="*"
        ;;
esac

. $(dirname $0)/common.sh

# hack with release part
[ "$VERSION" = "*" ] || VERSION="$VERSION-1"

case $(epm print info -p) in
    rpm)
        # https://download.r7-office.ru/organizer/centos/r7organizer-3.1.2-1.x86_64.rpm
        # alt version has other deps, but we repack in anyway
        mask="centos/r7organizer-$VERSION.x86_64.rpm"
        ;;
    *)
        # https://download.r7-office.ru/organizer/ubuntu/r7-organizer_3.1.2-1_amd64.deb
        mask="ubuntu/r7-organizer_${VERSION}_amd64.deb"
        ;;
esac


if [ "$VERSION" = "*" ] ; then
    PKGURL=$(eget -U --list --latest "https://r7-office.ru/downloadorganizer" "$mask")
else
    PKGURL="https://download.r7-office.ru/organizer/$mask"
fi

install_pkgurl
