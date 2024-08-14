#!/bin/sh

PKGNAME=sunshine
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Self-hosted game stream host for Moonlight"
URL="https://app.lizardbyte.dev/Sunshine"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
	VERSION="$(curl -s https://api.github.com/repos/LizardByte/Sunshine/releases/latest | grep -oP '"tag_name": "\K(.*?)(?=")' | sed 's/G//g')"
fi

PKGURL=https://github.com/LizardByte/Sunshine/releases/download/$VERSION/sunshine.AppImage

install_pkgurl
