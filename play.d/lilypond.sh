#!/bin/sh

PKGNAME=lilypond
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="LilyPond music engraving program"
URL="https://gitlab.com/lilypond/lilypond"

. $(dirname $0)/common.sh

# LilyPond uses an even minor for stable releases (2.24, 2.26) and an odd minor
# for development (2.25, 2.27), so pick the latest stable (minor ends in an even
# digit) rather than the latest release, which may be a development build.
[ "$VERSION" = "*" ] && VERSION="$(get_gitlab_tag "$URL" '^[0-9]+\.[0-9]*[02468]\.')"
PKGURL="$(get_gitlab_url "$URL" "lilypond-$VERSION-linux-x86_64.tar.gz")"

install_pkgurl
