#!/bin/sh

PKGNAME=orion-browser
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Orion is a WebKitGTK-based web browser by Kagi with built-in tracker blocking and privacy features.'
URL="https://orionbrowser.com/download/"

. $(dirname $0)/common.sh

epm assure ostree || fatal

if [ "$VERSION" = "*" ] ; then
   VERSION=$(eget -O- https://orionbrowser.com/platforms/linux | grep -oP 'oriongtk\.\K[0-9.]+(?=\.flatpak)' | head -n1)
fi

case "$(epm print info -a)" in
    x86_64)
        PKGURL="https://orionbrowser.com/download/oriongtk.$VERSION.flatpak"
        ;;
    aarch64)
        PKGURL="https://orionbrowser.com/download/oriongtk.$VERSION.arm.flatpak"
        ;;
esac

install_pack_pkgurl $VERSION
