#!/bin/sh

PKGNAME=bitwig-studio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Bitwig Studio from the official site"
URL="https://www.bitwig.com"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ]; then
    VERSION=$(eget -O- https://www.bitwig.com/download/ | grep -o "Bitwig Studio [0-9][0-9.]*" | head -1 | grep -o "[0-9][0-9.]*")
    [ -n "$VERSION" ] || fatal "Can't get version"
fi

cd_to_temp_dir

# URL redirects to .deb but saves as "installer_linux" without extension
PKGURL="$PKGNAME-$VERSION.deb"
eget -O "$PKGURL" "https://www.bitwig.com/dl/Bitwig%20Studio/$VERSION/installer_linux/"

install_pkgurl
