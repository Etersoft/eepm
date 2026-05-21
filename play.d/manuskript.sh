#!/bin/sh

PKGNAME=manuskript
SUPPORTEDARCHES=""
VERSION="$2"
RELEASE="$3"
DESCRIPTION="A open-source tool for writers for Linux from the official site"
URL="http://www.theologeek.ch/manuskript"

. $(dirname $0)/common.sh

case $(epm print info -p) in
    rpm)
        file="${PKGNAME}-${VERSION}-${RELEASE}.noarch.rpm"
        ;;
    *)
        file="${PKGNAME}-${VERSION}-${RELEASE}.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "https://github.com/olivierkes/manuskript" "$file")"
else
    PKGURL="https://github.com/olivierkes/manuskript/releases/download/$VERSION/$file"
fi

case "$(epm print info -s)" in
    debian)
        # Debian 13 has no QtWebKit package, patch the upstream deb dependency in pack.d before install.
        install_pack_pkgurl
        ;;
    *)
        install_pkgurl
        ;;
esac
