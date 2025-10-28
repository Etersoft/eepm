#!/bin/sh

PKGNAME=cloudflare-warp
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Cloudflare Warp Client"
URL="https://one.one.one.one/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION="$(eget -O- "https://developers.cloudflare.com/cloudflare-one/team-and-resources/devices/warp/download-warp/" \
| grep -oP -m 1 'Linux [0-9.]+' | awk '{print $2}')"

PKGURL="https://pkg.cloudflareclient.com/pool/noble/main/c/cloudflare-warp/cloudflare-warp_${VERSION}_amd64.deb"

install_pkgurl || fatal

cat <<EOF
Note: run
# serv warp-svc.service on
to start Cloudflare Warp permanently
and
$ systemctl --user start warp-taskbar.service 
to start the system tray icon.
EOF
