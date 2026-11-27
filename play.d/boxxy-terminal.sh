#!/bin/sh

PKGNAME=boxxy-terminal
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Boxxy Terminal repackaged from the official Flatpak repository"
URL="https://boxxy.dev/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

epm assure ostree || fatal

REPO_URL="https://boxxy-dev.github.io/boxxy-flatpak-remote/repo"
PKGURL="$REPO_URL/config"

install_pack_pkgurl
