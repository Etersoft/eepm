#!/bin/sh

PKGNAME=ridoclnx
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="RiDocLNX - scanner software for Linux"
URL="https://ridoclnx.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case $(epm print info -e) in
    AstraLinuxSE/1.8)
        mask="ridoclnx_${VERSION}astra18.deb"
        ;;
    AstraLinuxSE/1.7|AstraLinuxSE/1.7.5|AstraLinuxCE/1.6)
        mask="ridoclnx_${VERSION}astra17.deb"
        ;;
    RedOS/8*)
        mask="ridoclnx-${VERSION}REDOS8.x86_64.rpm"
        ;;
    RedOS/7*)
        mask="ridoclnx-${VERSION}REDOS7.x86_64.rpm"
        ;;
    ALTLinux/p11|ALTLinux/Sisyphus)
        mask="ridoclnx-${VERSION}P11ALT.x86_64.rpm"
        ;; 
    ALTLinux/p10|CentOS/*)
        mask="ridoclnx-${VERSION}ALT.x86_64.rpm"
        ;;
    Ubuntu/*)
        mask="ridoclnx_${VERSION}ubuntu22.deb"
        ;;
    Debian/*)
        mask="ridoclnx_${VERSION}debian12.deb"
        ;;
    *)
        mask="ridoclnx_${VERSION}ubuntu22.deb"
        ;;
esac


PKGURL=$(eget --list --latest "https://ridoclnx.com/download-ridoclnx-ru" "$mask")

install_pkgurl
