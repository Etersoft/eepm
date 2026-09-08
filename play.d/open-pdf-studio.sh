#!/bin/sh

PKGNAME=open-pdf-studio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Free, open-source PDF editor and annotator"
URL="https://github.com/OpenAEC-Foundation/open-pdf-studio"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag "$URL")
    [ -n "$VERSION" ] || fatal "Can't get version from GitHub"
fi

PKGURL="$URL/releases/download/v$VERSION/Open.PDF.Studio_${VERSION}_amd64.deb"

install_pkgurl
