#!/bin/sh

PKGNAME=open-pdf-studio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Free, open-source PDF editor and annotator"
URL="https://github.com/OpenAEC-Foundation/open-pdf-studio"

. $(dirname $0)/common.sh

# tag (v2026.39) differs from the version in the file name (2026.39.0)
PKGURL=$(get_github_url "$URL" "Open.PDF.Studio_${VERSION}_amd64.deb")

install_pkgurl
