#!/bin/sh

PKGNAME=Sunshine
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Self-hosted game stream host for Moonlight"
URL="https://app.lizardbyte.dev/Sunshine"

. $(dirname $0)/common.sh

warn_version_is_not_supported

is_openssl_enough 3 || fatal "There is no needed OpenSSL 3 in the system."

arch=$(epm print info -a)

# TODO: common way to install from Fedora copr
# use API instead of HTML page (Anubis bot protection blocks scraping)
BUILD_ID=$(epm tool json --get-json-value "https://copr.fedorainfracloud.org/api_3/build/list?ownername=lizardbyte&projectname=stable&packagename=Sunshine&status=succeeded" '["items",0,"id"]')

PKGURL=$(eget --list --latest https://download.copr.fedorainfracloud.org/results/lizardbyte/stable/fedora-41-$arch/0$BUILD_ID-Sunshine/ "Sunshine-*.$arch.rpm")

install_pkgurl

cat <<EOF

Note: run
# setcap cap_sys_admin+p $(readlink -f $(command -v sunshine))
to enable permissions for KMS capture (Capture of most Wayland-based desktop environments will fail unless this step is performed.)
EOF
