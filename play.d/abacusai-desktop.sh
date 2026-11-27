#!/bin/sh

PKGNAME=da-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="AbacusAI Desktop AI assistant"
URL="https://github.com/abacusai/deepagent-releases"

. $(dirname $0)/common.sh

case "$(epm print info -p)" in
    rpm)
        mask="abacusai-app-$VERSION-el8.$(epm print info -a).rpm"
        ;;
    *)
        mask="abacusai-app_${VERSION}_$(epm print info --debian-arch).deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "$mask")"
else
    PKGURL="$URL/releases/download/$VERSION/$mask"
fi

install_pkgurl
