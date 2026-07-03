#!/bin/sh

BASEPKGNAME=brave-origin
SUPPORTEDARCHES="x86_64 aarch64"
PRODUCTALT="'' beta nightly"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Brave Origin — streamlined Brave browser (free on Linux)"
URL="https://brave.com/origin/"

. $(dirname $0)/common.sh

# brave-origin-1.92.134-1.x86_64.rpm
# brave-origin_1.92.134_amd64.deb

# hack to fix short name issue
if [ "$VERSION" = "*" ] ; then
    VERSION="[[:digit:]]*"
    PKGURL=$(eget --list --latest https://github.com/brave/brave-browser/releases "$(epm print constructname $PKGNAME "$VERSION")")
else
    OVERSION="$VERSION"
    # rpm packages have a release in their names
    [ "$(epm print info -p)" = "rpm" ] && VERSION="${VERSION}-${RELEASE}"
    PKGURL="https://github.com/brave/brave-browser/releases/download/v$OVERSION/$(epm print constructname $PKGNAME "$VERSION")"
fi

[ -n "$PKGURL" ] || fatal "Can't get package URL for $PKGNAME-$VERSION"

# we have workaround for their postinstall script, so always repack rpm package
# repack for deb too, they have broken dependency on brave-keyring
epm install --repack "$PKGURL"
