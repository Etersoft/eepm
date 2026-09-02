#!/bin/sh

PKGNAME=gswitch
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Keyboard layout switcher with text correction for Linux (X11 + Wayland)"
URL="https://github.com/arumata/gswitch"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ]; then
    PKGURL=$(get_github_url "$URL" "${PKGNAME}_${VERSION}_linux_amd64.deb")
else
    PKGURL="${URL}/releases/download/v${VERSION}/${PKGNAME}_${VERSION}_linux_amd64.deb"
fi

install_pkgurl || exit

cat <<EOF
To start gswitch now and on login, run:
# serv --user gswitch on
EOF
