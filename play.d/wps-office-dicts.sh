#!/bin/sh

PKGNAME=wps-office-dicts
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Spellcheck dictionaries for WPS Office"
URL="https://github.com/slackalaxy/wps-office-dicts"
VERSION="$2"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ]; then
	VERSION="$(get_github_tag "https://github.com/slackalaxy/wps-office-dicts/")"
fi
PKGURL="https://github.com/slackalaxy/wps-office-dicts/archive/refs/tags/${VERSION}.zip"

install_pack_pkgurl $VERSION
