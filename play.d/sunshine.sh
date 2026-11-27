#!/bin/sh

PKGNAME=Sunshine
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Self-hosted game stream host for Moonlight"
TIPS="Run epm play Sunshine=<version> to install specific version (e.g. 2026.516.143833)."
URL="https://github.com/SunshineStream/Sunshine"

. $(dirname $0)/common.sh

is_openssl_enough 3 || fatal "There is no needed OpenSSL 3 in the system."

arch=$(epm print info -a)

# Use the Fedora 43 build (Fedora packages work for ALT via repack)
# Sunshine up to 2026.5xx links ICU 77, it is installed via epm play libicu77 in repack.d/Sunshine.sh
FEDORA=fc43

# Use GitHub releases
if [ "$VERSION" != "*" ] ; then
    # RELEASE from app-versions can be for another Fedora (1.fc42), take the build number only
    PKGURL="https://github.com/SunshineStream/Sunshine/releases/download/v${VERSION}/Sunshine-${VERSION}-${RELEASE%%.*}.$FEDORA.$arch.rpm"
else
    PKGURL=$(eget --list --latest https://github.com/SunshineStream/Sunshine/releases "Sunshine-*-*.$FEDORA.$arch.rpm")
fi

install_pkgurl

cat <<'EOF'

Note: run
# setcap cap_sys_admin+p /usr/bin/sunshine
to enable permissions for KMS capture (Capture of most Wayland-based desktop environments will fail unless this step is performed.)
EOF
