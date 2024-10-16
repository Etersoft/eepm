#!/bin/sh

PKGNAME="teamviewer"
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Teamviewer from the official site"
URL="https://www.teamviewer.com/ru-cis/download/linux"

. $(dirname $0)/common.sh

warn_version_is_not_supported


# See https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=teamviewer
# TODO: version support
PKGURL="ipfs://QmShWJX7rJ2wgTpLGdoUoGCXNutvMHr9YGnRuDF4Xc4RgF?filename=teamviewer.x86_64.rpm"

install_pkgurl

cat <<EOF

Note: run
# serv teamviewerd on
to enable needed teamviewer system service (daemon)
EOF
