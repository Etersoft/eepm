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

# due complex release part
warn_version_is_not_supported

case $(epm print info -p) in
    rpm)
        # https://download.r7-office.ru/centos/r7-office-2025.3.1-923.el8.x86_64.rpm
        mask="centos/r7-office-${VERSION}-*.x86_64.rpm"
        ;;
    *)
        # https://download.r7-office.ru/debian/r7-office_2025.3.1-923~stretch_amd64.deb
        mask="debian/r7-office_${VERSION}-*_amd64.deb"
        ;;
esac


case $(epm print info -e) in
    AstraLinuxSE/*)
        # https://download.r7-office.ru/astra/r7-office_2025.3.1-923~astra-signed_amd64.deb
        mask="astra/r7-office_${VERSION}-*_amd64.deb"
        ;;
    ROSA/*)
        # https://download.r7-office.ru/rosa/r7-office-2025.3.1-923.r9.x86_64.rpm
        mask="rosa/r7-office-${VERSION}-*.x86_64.rpm"
        ;;
    ALTLinux/*)
         # https://download.r7-office.ru/altlinux/r7-office-2025.3.1-923.p8.x86_64.rpm
         mask="altlinux/r7-office-${VERSION}-*.x86_64.rpm"
        ;;
    #*)
    #    fatal "Unsupported distro $(epm print info -e). Ask application vendor for a support."
    #    ;;
esac

case $(epm print info --distro-name) in
    "MOS Desktop")
        # https://download.r7-office.ru/desktop/mos/r7-office-2025.3.1-923.r9-mos.x86_64.rpm
        mask="desktop/mos/r7-office-${VERSION}-*.x86_64.rpm"
        ;;
esac


PKGURL="$(eget --list --latest -U  "$URLBASE" "$mask")"

install_pkgurl
