#!/bin/sh

PKGNAME=photosuite
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="PhotoSuite - image editor with native PSD/PSB support"
URL="https://github.com/eolix/photosuite"

. $(dirname $0)/common.sh

# https://github.com/eolix/photosuite/releases/download/v0.9.20/photosuite-0.9.20-linux-x86_64.rpm
case $(epm print info -p) in
    rpm)
        mask="photosuite-${VERSION}-linux-x86_64.rpm"
        ;;
    *)
        mask="photosuite-${VERSION}-linux-x86_64.deb"
        ;;
esac

PKGURL=$(get_github_url "$URL" "$mask")

install_pkgurl
