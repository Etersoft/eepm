#!/bin/sh

PKGNAME=r7organizer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="R7 Office Organizer for Linux from the official site"
URL="https://support.r7-office.ru/download/organizer/"

# fixme: global epm is used
case $(epm print info -p) in
    deb)
        PKGNAME="r7-organizer"
        # force latest version due broken package name
        VERSION="*"
        ;;
esac

. $(dirname $0)/common.sh

# append release to version
[ "$VERSION" = "*" ] || VERSION="${VERSION}-${RELEASE}"

case $(epm print info -p) in
    rpm)
        # upstream now publishes generic rpm on the support page
        # https://download.r7-office.ru/organizer/centos/r7organizer-3.1.2-1.x86_64.rpm
        mask="centos/r7organizer-$VERSION.x86_64.rpm"
        ;;
    *)
        # https://download.r7-office.ru/organizer/ubuntu/r7-organizer_3.1.2-1_amd64.deb
        mask="ubuntu/r7-organizer_${VERSION}_amd64.deb"
        ;;
esac

case $(epm print info -e) in
    AstraLinuxSE/*)
        # https://download.r7-office.ru/organizer/astra/r7-organizer_3.1.2-1_astralinux-signed_amd64.deb
        mask="astra/r7-organizer_${VERSION}_astralinux-signed_amd64.deb"
        ;;
    ALTLinux/*)
        # https://download.r7-office.ru/organizer/alt/r7organizer-3.1.2-1_altlinux.x86_64.rpm
        mask="alt/r7organizer-${VERSION}_altlinux.x86_64.rpm"
        ;;
esac


if [ "$VERSION" = "*" ] ; then
    # parse the support page, because the old vendor landing now redirects elsewhere
    PKGURL=$(eget -U --list --latest "$URL" "$mask")
else
    PKGURL="https://download.r7-office.ru/organizer/$mask"
fi

install_pkgurl
