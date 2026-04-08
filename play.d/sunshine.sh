#!/bin/sh

PKGNAME=Sunshine
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Self-hosted game stream host for Moonlight"
TIPS="Run epm play Sunshine=<version> to install specific version (e.g. 2025.924.154138)."
URL="https://github.com/LizardByte/Sunshine"

. $(dirname $0)/common.sh

is_openssl_enough 3 || fatal "There is no needed OpenSSL 3 in the system."

arch=$(epm print info -a)

# Use GitHub releases (Fedora 41 packages work for ALT via repack)
if [ "$VERSION" != "*" ] ; then
    PKGURL="https://github.com/LizardByte/Sunshine/releases/download/v${VERSION}/Sunshine-${VERSION}-${RELEASE}.$arch.rpm"
else
    PKGURL=$(eget --list --latest https://github.com/LizardByte/Sunshine/releases "Sunshine-*-*.fc41.$arch.rpm")
fi

install_pkgurl

cat <<'EOF'

Note: run
# setcap cap_sys_admin+p /usr/bin/sunshine
to enable permissions for KMS capture (Capture of most Wayland-based desktop environments will fail unless this step is performed.)
EOF
