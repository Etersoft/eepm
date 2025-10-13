#!/bin/sh

PKGNAME=ElyPrismLauncher-Linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Fork of Prism Launcher adds integrated support for Ely.by accounts (MSA accounts can still be used)'
URL="https://github.com/ElyPrismLauncher/ElyPrismLauncher"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch=x86_64
#if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/ElyPrismLauncher/ElyPrismLauncher/" "ElyPrismLauncher-Linux-x86_64.AppImage")
#else
#    PKGURL="https://github.com/ElyPrismLauncher/ElyPrismLauncher/releases/download/$VERSION/ElyPrismLauncher-Linux-x86_64.AppImage"
#fi

install_pkgurl
