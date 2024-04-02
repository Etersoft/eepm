#!/bin/sh

PKGNAME=r7-organizer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="R7 Office Organizer for Linux from the official site"
URL="https://r7-office.ru/downloadorganizer"

# fixme: global epm is used
case $(epm print info -e) in
    ALTLinux/*)
        PKGNAME="r7organizer"
        ;;
esac

. $(dirname $0)/common.sh

# TODO: add repack with conflicts to r7-office-organizer, r7-organizer-pro

# hack with release part
[ "$VERSION" = "*" ] || VERSION="$VERSION-1"

#arch=$(epm print info --distro-arch)

case $(epm print info -p) in
    rpm)
        mask="centos/r7organizer-$VERSION.x86_64.rpm"
        ;;
    *)
        mask="ubuntu/r7-organizer_${VERSION}_ubuntu-20.04_amd64.deb"
        ;;
esac

case $(epm print info -e) in
    AstraLinuxSE/*)
        mask="astra/r7-organizer_${VERSION}_astralinux-signed_amd64.deb"
        ;;
#    Ubuntu/*)
#        mask="ubuntu/r7-organizer_${VERSION}_ubuntu-20.04_amd64.deb"
#        ;;
    ALTLinux/*)
        mask="alt/r7organizer-${VERSION}_altlinux.x86_64.rpm"
        #override_pkgname "r7organizer"
        ;;
esac


if [ "$VERSION" = "*" ] ; then
    PKGURL=$(eget -U --list --latest "https://r7-office.ru/downloadorganizer" "$mask")
else
    PKGURL="https://download.r7-office.ru/organizer/$mask"
fi

# install with scripts (need for install icons and associations)
# see /etc/eepm/pkgallowscripts.list
# TODO: pack it into the package
epm install --scripts "$PKGURL"
