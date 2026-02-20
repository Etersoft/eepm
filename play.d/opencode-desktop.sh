#!/bin/sh

PKGNAME=open-code
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="OpenCode desktop client"
URL="https://opencode.ai"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

warn_version_is_not_supported

case $pkgtype in
    rpm)
        pkgformat="rpm"
        arch=$(epm print info -a)
        ;;
    *)
        pkgformat="deb"
        arch=$(epm print info --debian-arch)
        ;;
esac

PKGURL=$(get_github_url https://github.com/anomalyco/opencode "opencode-desktop-linux-$arch.$pkgformat")

install_pkgurl
