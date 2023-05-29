#!/bin/sh

PKGNAME=r7-office-organizer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="R7 Office Organizer for Linux from the official site"
URL="https://support.r7-office.ru/category/organizer/install_organizer/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="68.5.0"
fi

# hack with release part
[ "$VERSION" = "68.5.0" ] && VERSION="$VERSION-5"

case $(epm print info -p) in
    rpm)
        PKGURL="https://download.r7-office.ru/centos/r7-office-organizer-$VERSION-centos.ru.x86_64.rpm"
        ;;
    *)
        PKGURL="https://download.r7-office.ru/ubuntu/r7-office-organizer-$VERSION.ru.x86_64.deb"
        ;;
esac

case $(epm print info -e) in
    ROSA/2021.1)
        PKGURL="https://download.r7-office.ru/rosa/r7-office-organizer-$VERSION-rosa.ru.x86_64.rpm"
        ;;
    ALTLinux/*)
        PKGURL="https://download.r7-office.ru/altlinux/r7-office-organizer-$VERSION-altlinux.ru.x86_64.rpm"
        ;;
esac

# install with scripts (need for install icons and associations)
# see /etc/eepm/pkgallowscripts.list
# TODO: pack it into the package
epm install "$PKGURL"
