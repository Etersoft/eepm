#!/bin/sh

PKGNAME=activinspire
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Promethean ActivInspire - software for ActivBoard and ActivPanel interactive whiteboards"
URL="https://support.prometheanworld.com/product/activinspire"

. $(dirname $0)/common.sh

REPO="https://activsoftware.co.uk/linux/repos/ubuntu"

if [ "$VERSION" = "*" ] ; then
    # Filename: pool/focal/a/ac/activinspire_2004-3.5.18-1-amd64.deb
    file="$(fetch_url "$REPO/dists/focal/non-oss/binary-amd64/Packages" | awk -v RS= '/(^|\n)Package: activinspire\n/' | sed -n 's|^Filename: ||p' | tail -n1)"
    [ -n "$file" ] || fatal "Can't get package URL for $PKGNAME"
    PKGURL="$REPO/$file"
else
    PKGURL="$REPO/pool/focal/a/ac/activinspire_2004-$VERSION-1-amd64.deb"
fi

install_pkgurl
