#!/bin/sh

PKGNAME=flameshot
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Powerful yet simple to use screenshot software"
URL="https://github.com/flameshot-org/flameshot"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag https://github.com/flameshot-org/flameshot)"
    RELEASE="1"
fi

pkgtype=$(epm print info -p)

case "$pkgtype" in
    rpm)
        PKGURL=$(get_github_url flameshot-org/flameshot "flameshot-${VERSION}-*.x86_64.rpm")
        ;;
    *)
        debvariant="ubuntu-22.04"
        case "$(epm print info -s)" in
            debian)
                debvariant="debian-12"
                ;;
        esac
        asset="flameshot-${VERSION}-${RELEASE}.${debvariant}.amd64.deb"
        PKGURL="https://github.com/flameshot-org/flameshot/releases/download/v$VERSION/$asset"
        ;;
esac

install_pkgurl
