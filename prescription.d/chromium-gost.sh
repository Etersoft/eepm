#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

[ "$1" != "--run" ] && echo "Install Chromium with GOST support from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

#arch=$($DISTRVENDOR --distro-arch)
#pkgtype=$($DISTRVENDOR -p)
arch=amd64
pkgtype=deb

PKG=$($EGET --list --latest https://github.com/deemru/chromium-gost/releases "chromium-gost-*linux-$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKG"
