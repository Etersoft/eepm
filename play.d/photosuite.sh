#!/bin/sh

PKGNAME=photo-suite
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="PhotoSuite - image editor with native PSD/PSB support"
URL="https://github.com/eolix/photosuite"

. $(dirname $0)/common.sh

case $(epm print info -p) in
    rpm)
        mask="PhotoSuite-${VERSION}-*.x86_64.rpm"
        ;;
    *)
        mask="PhotoSuite_${VERSION}_amd64.deb"
        ;;
esac

PKGURL=$(get_github_url "$URL" "$mask")

install_pkgurl
