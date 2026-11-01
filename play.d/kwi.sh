#!/bin/sh

PKGNAME=kwi
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Kwi nightly terminal for KDE Plasma and other desktops'
URL="https://invent.kde.org/utilities/kwi"

. $(dirname $0)/common.sh

warn_version_is_not_supported

epm assure ostree || fatal

PKGURL="https://cdn.kde.org/flatpak/kwi-nightly/org.kde.kwi.flatpakref"
install_pack_pkgurl
