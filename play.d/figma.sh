#!/bin/sh

PKGNAME=figma-linux-next
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Figma Linux Next - an unofficial Electron-based Figma desktop app for Linux"
URL="https://github.com/arximus88/figma-linux-next"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="[0-9]*"

pkgtype="$(epm print info -p)"

# Figma Linux Next uses Debian architecture names for .deb and distro
# architecture names for .rpm. Its Pacman build is currently x86_64 only.
case "$pkgtype" in
    deb)
        arch="$(epm print info --debian-arch)"
        ;;
    rpm)
        arch="$(epm print info --distro-arch)"
        ;;
    pacman)
        case "$(epm print info -a)" in
            x86_64)
                arch=x64
                ;;
            *)
                fatal "Figma Linux Next does not publish a Pacman package for this architecture"
                ;;
        esac
        ;;
    *)
        fatal "$pkgtype package format is not supported"
        ;;
esac

file="${PKGNAME}_${VERSION}_linux_${arch}.${pkgtype}"
PKGURL=$(get_github_url "$URL" "$file")

install_pkgurl
