#!/bin/sh

PKGNAME=Bastyon
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Bastyon is a decentralized, open-source social network and video sharing platform."
URL="https://bastyon.com/applications"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(eget --list --latest "https://github.com/pocketnetteam/pocketnet.gui/releases" "Bastyon.AppImage")

install_pkgurl
