#!/bin/sh

PKGNAME=sunshine
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Self-hosted game stream host for Moonlight"
URL="https://app.lizardbyte.dev/Sunshine"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url "https://github.com/LizardByte/Sunshine/" "sunshine-fedora-.*-amd64.rpm")

install_pkgurl

cat <<EOF

Note: run
# setcap cap_sys_admin+p $(readlink -f $(command -v sunshine))
to enable permissions for KMS capture (Capture of most Wayland-based desktop environments will fail unless this step is performed.)
EOF
