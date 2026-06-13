#!/bin/sh

PKGNAME=waywallen
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Dynamic wallpaper solution for Linux desktops"
URL="https://github.com/waywallen/waywallen"
DISPLAY_URL="https://github.com/waywallen/waywallen-display"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "$PKGNAME-*-x86_64.AppImage")
else
    PKGURL="$URL/releases/download/v$VERSION/$PKGNAME-$VERSION-x86_64.AppImage"
fi

install_pkgurl || exit

DISPLAY_VERSION="$(get_github_tag "$DISPLAY_URL" | sed -e 's|^v||')"

[ -n "$DISPLAY_VERSION" ] || DISPLAY_VERSION="<version>"

cat <<EOF

Note: run
$ serv --user waywallen on
to enable and start Waywallen wallpaper daemon.

Desktop integration for KDE Plasma and GNOME Shell is available separately:
$DISPLAY_URL

KDE Plasma 6:
$ eget -O /tmp/waywallen-kde-$DISPLAY_VERSION-x86_64-embed.zip $DISPLAY_URL/releases/download/v$DISPLAY_VERSION/waywallen-kde-$DISPLAY_VERSION-x86_64-embed.zip
$ kpackagetool6 --type Plasma/Wallpaper -u /tmp/waywallen-kde-$DISPLAY_VERSION-x86_64-embed.zip || kpackagetool6 --type Plasma/Wallpaper -i /tmp/waywallen-kde-$DISPLAY_VERSION-x86_64-embed.zip
This command upgrades the KDE Plasma extension if it is already installed, or installs it otherwise.
$ systemctl --user restart plasma-plasmashell.service

GNOME Shell 48+:
$ eget -O /tmp/waywallen-gnome-$DISPLAY_VERSION-x86_64.zip $DISPLAY_URL/releases/download/v$DISPLAY_VERSION/waywallen-gnome-$DISPLAY_VERSION-x86_64.zip
$ gnome-extensions install --force /tmp/waywallen-gnome-$DISPLAY_VERSION-x86_64.zip
$ gnome-extensions enable org.waywallen.gnome@waywallen.io

Log out and back in to load the GNOME Shell extension.
EOF
