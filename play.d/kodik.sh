#!/bin/sh

PKGNAME=kodik
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Kodik — это первая российская AI-IDE, которая действует как второй разработчик"
URL="https://kodik.ru"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -a)" in
    x86_64)
        pkgarch=x64
        ;;
    aarch64)
        pkgarch=arm64
        ;;
esac

case "$(epm print info -p)" in
    rpm)
        pkgtype=rpm
        ;;
    *)
        pkgtype=deb
        ;;
esac

APIURL="https://api.vibekodik.ru/v1"
platform="linux-$pkgarch-$pkgtype"
# 0.0.0 makes the update API always return the latest release.
# https://api.vibekodik.ru/v1/update/linux-arm64-rpm/0.0.0
PKGURL="$(get_json_value "$APIURL/update/$platform/0.0.0" url)"
[ -n "$PKGURL" ] || fatal "Can't get Kodik $pkgarch $pkgtype package URL"

install_pkgurl
