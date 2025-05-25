#!/bin/sh

PKGNAME=Murglar-Desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Desktop player/downloader for popular music streaming services"
URL="https://murglar.app"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/badmannersteam/murglar-downloads/releases "Murglar-Desktop-$VERSION-linux-x64.appimage")

install_pkgurl

