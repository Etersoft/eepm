#!/bin/sh

PKGNAME=mattermost-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Mattermost Desktop application for Linux from the official site"
URL="https://mattermost.com/"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"

PKGURL=$(get_github_url "https://github.com/mattermost/desktop/" "$(epm print constructname $PKGNAME ".$VERSION*" $arch "deb")")

install_pkgurl

