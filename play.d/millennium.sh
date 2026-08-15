#!/bin/sh

PKGNAME=millennium
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Open-source modding framework for Steam Client themes and plugins"
URL="https://github.com/SteamClientHomebrew/Millennium"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag "$URL")
fi

PKGURL="$URL/releases/download/v$VERSION/millennium-v$VERSION-linux-x86_64.tar.gz"

install_pack_pkgurl || exit

cat <<EOF

Run millennium-setup as a regular user to enable Millennium for Steam.
Millennium doesn't support Steam installed via Flatpak or Snap.
EOF
