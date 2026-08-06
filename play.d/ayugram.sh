#!/bin/sh

PKGNAME=ayugram-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Desktop Telegram client with good customization and Ghost mode"
URL="https://github.com/AyuGram/AyuGramDesktop"
FLATPAK_URL="https://github.com/0FL01/AyuGramDesktop-flatpak"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Official AyuGram Linux deb/AppImage builds are not published yet. The old
# Arch binary package links against rolling Arch libraries and is not portable.
epm assure ostree || fatal

PKGURL=$(get_github_url "$FLATPAK_URL" "ayugram-desktop-*.flatpak")

install_pack_pkgurl
