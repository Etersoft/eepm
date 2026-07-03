#!/bin/sh

PKGNAME=orion
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Orion Browser by Kagi (WebKitGTK/GTK4) — Linux beta, repacked from the official Flatpak bundle'
URL="https://orionbrowser.com/platforms/linux"

. $(dirname $0)/common.sh

# the app ships as a Flatpak bundle; erc unpacks it via ostree (no flatpak needed)
epm assure ostree || fatal

# Orion's bundled WebKit was built against the GNOME 49 runtime and links
# libicu*.so.77, which ALT (ICU <= 76) does not ship. Provide it first.
if ! ls /usr/lib64/libicudata.so.77 /usr/lib/libicudata.so.77 >/dev/null 2>&1 ; then
    epm play libicu77 || fatal "Can't install libicu77 (needed for libicu*.so.77)"
fi

# the vendor publishes only the current version
case "$VERSION" in ""|"*") VERSION="0.3.0" ;; esac

case "$(epm print info -a)" in
    x86_64)  PKGURL="https://orionbrowser.com/download/oriongtk.$VERSION.flatpak" ;;
    aarch64) PKGURL="https://orionbrowser.com/download/oriongtk.$VERSION.arm.flatpak" ;;
    *) fatal "Unsupported architecture for $PKGNAME" ;;
esac

install_pack_pkgurl "$VERSION"
