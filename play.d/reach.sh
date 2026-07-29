#!/bin/sh

PKGNAME=reach
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION=" A modern, cross-platform SSH client and remote management tool."
URL="https://github.com/alexandrosnt/Reach"

. $(dirname $0)/common.sh

case $(epm print info -p) in
    rpm)
        mask="Reach-${VERSION}-*.x86_64.rpm"
        ;;
    *)
        mask="Reach_${VERSION}_amd64.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/alexandrosnt/Reach" "$mask")
else
    PKGURL="https://github.com/alexandrosnt/Reach/releases/download/v${VERSION}/$mask"
fi

install_pkgurl

