#!/bin/sh

PKGNAME=jellyfin-web
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Web client for Jellyfin."
URL="https://jellyfin.org/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=$(epm print info -a)

PKGURL=$(eget --list --latest "https://download1.rpmfusion.org/free/fedora/releases/42/Everything/$arch/os/Packages/j/" "jellyfin-web*.rpm")

install_pkgurl
