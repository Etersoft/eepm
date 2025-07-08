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

BUILD_ID=$(eget --list https://copr.fedorainfracloud.org/coprs/lizardbyte/stable/package/Sunshine/ | grep -o 'build/[0-9]\+' | cut -d/ -f2 | sort -n | tail -n1)

PKGURL=$(eget --list --latest https://download.copr.fedorainfracloud.org/results/lizardbyte/stable/fedora-41-$arch/0$BUILD_ID-Sunshine/ "Sunshine-*.$arch.rpm")

install_pkgurl

cat <<EOF

Note: run
# setcap cap_sys_admin+p $(readlink -f $(command -v sunshine))
to enable permissions for KMS capture (Capture of most Wayland-based desktop environments will fail unless this step is performed.)
EOF
