#!/bin/sh

PKGNAME=PrismLauncher-Linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Minecraft launcher with the ability to manage multiple instances'
URL="https://github.com/PrismLauncher/PrismLauncher"

. $(dirname $0)/common.sh

arch=x86_64
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/PrismLauncher/PrismLauncher" "PrismLauncher-Linux-${arch}.AppImage")
else
    PKGURL="https://github.com/PrismLauncher/PrismLauncher/releases/download/$VERSION/PrismLauncher-Linux-${arch}.AppImage"
fi

install_pkgurl
