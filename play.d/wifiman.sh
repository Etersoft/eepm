#!/bin/sh

PKGNAME=wifiman-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A free network analysis tool with device discovery and Teleport VPN functionality"
URL="https://ui.com/download/app/wifiman-desktop"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(get_json_value "https://desktop.wifiman.com/wifiman-desktop-linux-manifest.json" '["platforms","linux-x86_64"]')"

install_pkgurl || exit
cat <<EOF
Note: run
# serv wifiman-desktop on
to start the required system service
EOF
