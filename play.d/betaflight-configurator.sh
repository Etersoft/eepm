#!/bin/sh

PKGNAME=betaflight-configurator
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Cross platform configuration tool for the Betaflight firmware."
URL="https://github.com/betaflight/betaflight-configurator/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ]; then
	PKGURL=$(get_github_url "https://github.com/betaflight/betaflight-configurator/" "betaflight-configurator_${VERSION}_amd64.deb")
else
	PKGURL="https://github.com/betaflight/betaflight-configurator/releases/download/$VERSION/betaflight-configurator_${VERSION}_amd64.deb"
fi

install_pkgurl
