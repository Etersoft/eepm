#!/bin/sh

PKGNAME=r7-organizer-pro
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="R7 Office Organizer Pro for Linux from the official site"
URL="https://r7-office.ru/downloadorganizer"

. $(dirname $0)/common.sh

case $(epm print info -p) in
    rpm)
        # https://download.r7-office.ru/organizer/centos/r7-organizer-pro-3.5.5.1-redos7.x86_64.rpm
        mask="centos/r7organizer_pro-$VERSION.x86_64.rpm"
        ;;
    *)
        # https://download.r7-office.ru/organizer/debian/r7-organizer-pro_3.6.4.0-debian12_amd64.deb
        mask="debian/r7-organizer_pro_${VERSION}-debian12_amd64.deb"
        ;;
esac

case $(epm print info -e) in
    AstraLinuxSE/*)
        # https://download.r7-office.ru/organizer/astra/r7-organizer-pro_3.6.4.0-astralinux_amd64.deb
        mask="astra/r7-organizer-pro_${VERSION}-astralinux_amd64.deb"
        ;;
#    ALTLinux/*)
#        mask="alt/r7-organizer-pro-${VERSION}-altlinux.x86_64.rpm"
#        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(eget -U --list --latest "https://r7-office.ru/downloadorganizer" "$mask")
else
    PKGURL="https://download.r7-office.ru/organizer/$mask"
fi

install_pkgurl
