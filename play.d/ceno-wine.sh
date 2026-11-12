#!/bin/sh

PKGNAME=ceno-wine
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Ceno Browser - censorship-resistant web browser (Windows version via Wine)"
URL="https://ceno.app/download/"

. $(dirname $0)/common.sh

API="https://gitlab.com/api/v4/projects/ceno-app%2Fceno-desktop/releases"
if [ "$VERSION" = "*" ] ; then
    RELEASE="$(fetch_url "$API?per_page=1")" || fatal "Can't get latest Ceno release"
else
    VERSION="${VERSION#v}"
    RELEASE="$(fetch_url "$API/v$VERSION")" || fatal "Can't get Ceno release $VERSION"
fi

PKGURL="$(echo "$RELEASE" | __get_gitlab_download_urls | grep -E '/ceno-win64-portable-[0-9][^/]*\.exe$' | head -n1)"
[ -n "$PKGURL" ] || fatal "Can't get Ceno portable installer URL"
VERSION="$(basename "$PKGURL" | sed -e 's|^ceno-win64-portable-\([0-9.]*\)-.*|\1|')"

if [ -z "$print_url" ] && ! is_command wine ; then
    epm play wine || fatal
fi

install_pack_pkgurl "$VERSION"
