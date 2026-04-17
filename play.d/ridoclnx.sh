#!/bin/sh

PKGNAME=ridoclnx
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="RiDocLNX - scanner software for Linux"
URL="https://riman.ru/ridoclnx"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Filename: ridoclnx-VERSION-RELEASE.arch.rpm where RELEASE = build<distroSuffix> (e.g. 7.9P11ALT)
# If we have RELEASE from app-versions and it matches the current distro suffix, use direct URL
# Otherwise glob the build between VERSION and the suffix
case $(epm print info -e) in
    AstraLinuxSE/1.8)            suffix=astra18; ext=deb; sep=_ ;;
    AstraLinuxSE/1.7|AstraLinuxSE/1.7.5|AstraLinuxCE/1.6)
                                 suffix=astra17; ext=deb; sep=_ ;;
    RedOS/8*|MSVSphere/*)        suffix=REDOS8;  ext=rpm; sep=- ;;
    RedOS/7*)                    suffix=REDOS7;  ext=rpm; sep=- ;;
    ALTLinux/p11|ALTLinux/Sisyphus)
                                 suffix=P11ALT;  ext=rpm; sep=- ;;
    ALTLinux/*|CentOS/*)         suffix=ALT;     ext=rpm; sep=- ;;
    Ubuntu/*)                    suffix=ubuntu22; ext=deb; sep=_ ;;
    Debian/*)                    suffix=debian12; ext=deb; sep=_ ;;
    *)                           suffix=ubuntu22; ext=deb; sep=_ ;;
esac

archpart=""
[ "$ext" = "rpm" ] && archpart=".x86_64"

case "$RELEASE" in
    *${suffix})
        # release matches our distro: build deterministic filename for IPFS lookup
        mask="ridoclnx${sep}${VERSION}-${RELEASE}${archpart}.${ext}"
        ;;
    *)
        # glob the build number for scraping
        mask="ridoclnx${sep}${VERSION}-*${suffix}${archpart}.${ext}"
        ;;
esac


PKGURL=$(eget --list --latest "https://riman.ru/download_ridoclnx_ru" "$mask")

install_pkgurl
