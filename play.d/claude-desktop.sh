#!/bin/sh

PKGNAME=claude-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Claude Desktop (Unofficial native client)"
URL="https://github.com/aaddrick/claude-desktop-debian"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

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

warn_version_is_not_supported

# TAG v1.3.17%2Bclaude1.1.5749 create broken VERSION drop this
PKGURL=$(get_github_url https://github.com/aaddrick/claude-desktop-debian "claude-desktop*$arch.$pkgformat")

install_pkgurl
