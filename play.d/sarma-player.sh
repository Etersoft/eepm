#!/bin/sh

PKGNAME=Sarma.Player
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Sarma.Player (Сарма.Плеер) video player, demo version from the official site"
URL="https://rapo.dev/spl/"
TIPS="The demo version plays up to 3 files in a playlist and 6 minutes per session. Codecs are not included: install VLC with codecs (epm install vlc)."

. $(dirname $0)/common.sh

# only the latest build is published
warn_version_is_not_supported

# the page links to https://download.rapo.dev:7443/..., but that port is not available, use 443
# https://download.rapo.dev/Sarma.Player-1.0.8.4_ALTLinux.demo.rpm
if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "$URL" | grep -o 'Sarma\.Player-[0-9.]*_ALTLinux\.demo\.rpm' | sed -e 's|^Sarma\.Player-||' -e 's|_ALTLinux\.demo\.rpm$||' | sort -V | tail -n1)"
    [ -n "$VERSION" ] || fatal "Can't get latest version from $URL"
fi

PKGURL="https://download.rapo.dev/Sarma.Player-${VERSION}_ALTLinux.demo.rpm"

install_pkgurl || exit

echo
info 'This is a demo version: up to 3 files in a playlist, 6 minutes per session.'
info 'Sarma.Player uses libvlc and does not include codecs, install VLC with its plugins if needed: epm install vlc'
