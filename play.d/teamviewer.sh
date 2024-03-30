#!/bin/sh

PKGNAME="teamviewer"
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Teamviewer from the official site"
URL="https://www.teamviewer.com/ru-cis/download/linux"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=$(epm print info --distro-arch)

# See https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=teamviewer

# TODO: version support
# https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.51.5.x86_64.rpm

repack=''
[ "$(epm print info -p)" = "deb" ] || repack='--repack'

# epm uses eget to download * names
epm $repack install "https://download.teamviewer.com/download/linux/$(epm print constructname $PKGNAME)" || exit

cat <<EOF

Note: run
# serv teamviewerd on
to enable needed teamviewer system service (daemon)
EOF
