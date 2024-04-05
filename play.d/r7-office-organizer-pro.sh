#!/bin/sh

PKGNAME=r7-organizer_pro
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="R7 Office Organizer Pro for Linux from the official site"
URL="https://r7-office.ru/downloadorganizer"

# fixme: global epm is used
case $(epm print info -e) in
    ALTLinux/*)
        PKGNAME="r7organizer"
        # force latest version due broken package name
        VERSION="*"
        ;;
esac

. $(dirname $0)/common.sh

# hack with release part
[ "$VERSION" = "*" ] || VERSION="$VERSION-1"

#arch=$(epm print info --distro-arch)

case $(epm print info -p) in
    rpm)
        mask="centos/r7organizer_pro-$VERSION.x86_64.rpm"
        ;;
    *)
        mask="ubuntu/r7-organizer_pro_${VERSION}_amd64.deb"
        ;;
esac

case $(epm print info -e) in
    AstraLinuxSE/*)
        mask="astra/r7-organizer_pro_${VERSION}_astralinux-signed_amd64.deb"
        ;;
    ALTLinux/*)
        mask="alt/r7organizer_pro-${VERSION}_altlinux.x86_64.rpm"
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
