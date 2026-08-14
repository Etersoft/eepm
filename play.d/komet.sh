#!/bin/sh

PKGNAME=komet
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Komet - альтернативный клиент MAX с расширенными настройками и акцентом на приватность"
URL="https://github.com/KometTeam/Komet"

. $(dirname $0)/common.sh

# get_github_url first selects a stable release and falls back to all releases,
# which keeps pre-releases installable until the first stable Komet release.
PKGURL=$(get_github_url "$URL" "Komet-linux-x64.tar.gz")

# Keep the selected release version in the generated package metadata.
if [ "$VERSION" = "*" ] ; then
    VERSION="$(basename "$(dirname "$PKGURL")" | sed 's/^v//')"
fi
# RPM version fields do not allow hyphens; retain prerelease ordering with ~.
VERSION="$(echo "$VERSION" | sed 's/-/~/')"

install_pack_pkgurl "$VERSION"
