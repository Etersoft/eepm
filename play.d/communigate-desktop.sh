#!/bin/sh

PKGNAME=communigate-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="CommuniGate Desktop (mail, calendar, messenger client for CommuniGate Pro, Samoware successor) from the official site"
URL="https://communigatepro.ru/client"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # https://doc.communigatepro.ru/packages/Desktop/1.2.0-release/communigate-desktop_1.2.0_alt11.rpm
    VERSION="$(fetch_url "$URL" | grep -o 'packages/Desktop/[0-9][0-9.]*-release/communigate-desktop_' | head -n1 | sed -e 's|packages/Desktop/\([0-9.]*\)-release/.*|\1|')"
    [ -n "$VERSION" ] || fatal "Can't get version."
fi

url="https://doc.communigatepro.ru/packages/Desktop/$VERSION-release"

case "$(epm print info -e)" in
    ALTLinux/p10)
        PKGURL="$url/communigate-desktop_${VERSION}_alt10.rpm"
        ;;
    ALTLinux/*)
        PKGURL="$url/communigate-desktop_${VERSION}_alt11.rpm"
        ;;
    *)
        case "$(epm print info -p)" in
            rpm)
                # RHEL 8 / RED OS 8 and RHEL 7 / RED OS 7.3 builds
                if is_glibc_enough 2.28 ; then
                    PKGURL="$url/communigate-desktop_${VERSION}_redos8.rpm"
                else
                    PKGURL="$url/communigate-desktop_${VERSION}_redos7.3.rpm"
                fi
                ;;
            deb)
                # bookworm: Ubuntu 22.04+, Debian 11+, Astra 1.8; buster: Ubuntu 20.04, Debian 10, Astra 1.7
                if is_glibc_enough 2.34 ; then
                    PKGURL="$url/communigate-desktop_${VERSION}-1~bookworm_amd64.deb"
                else
                    PKGURL="$url/communigate-desktop_${VERSION}-1~buster_amd64.deb"
                fi
                ;;
            *)
                PKGURL="$url/communigate-desktop_${VERSION}_alt11.rpm"
                ;;
        esac
        ;;
esac

install_pkgurl
