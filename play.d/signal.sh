#!/bin/sh

PKGNAME=signal-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Signal private messenger from the official site'
DOWNURL="https://updates.signal.org/desktop/apt/pool/main/s/signal-desktop"
URL="https://github.com/signalapp/Signal-Desktop/releases/"

. $(dirname $0)/common.sh

# Direct link to download .deb package
# https://github.com/signalapp/Signal-Desktop/issues/3506

if [ "$VERSION" = "*" ]; then
    VERSION="$(get_github_tag https://github.com/signalapp/Signal-Desktop/)"
fi

# signal-desktop_5.63.1_amd64.deb
file=signal-desktop_${VERSION}_amd64.deb

PKGURL="https://updates.signal.org/desktop/apt/pool/s/signal-desktop/$file"

install_pkgurl
