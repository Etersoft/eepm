#!/bin/sh

PKGNAME=cascadeur
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Cascadeur - a physics‑based 3D animation software"
URL="https://cascadeur.com/download"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# keep worked version
VERSION="2022.3.1"
PKGURL="ipfs://Qma8WF8iPwgKNPM6UdZHWse4q1cTnPAvjMRkGsbbWYi18w?filename=cascadeur-linux.tgz"
# TODO: ask license
epm pack --install $PKGNAME "$PKGURL" "$VERSION"
exit

# (liblapack.so.3)
page="$(eget -O- https://cascadeur.com/ru/download)"
BUILDID=$(echo "$page" | grep 'data-platform="linux"' | grep 'data-build-id=' | sed -e 's|.*data-build-id="\(.*\)" data-modal.*|\1|') #"
VERSION=$(echo "$page" | grep 'main-download__info-version' | sed -e 's|.*<div class="main-download__info-version">\(.*\)</div>.*|\1|') #'
# https://cdn.cascadeur.com/builds/linux/62/cascadeur-linux_2023.1.tgz
PKGURL="https://cdn.cascadeur.com/builds/linux/$BUILDID/cascadeur-linux_$VERSION.tgz"

# TODO: ask license
epm pack --install $PKGNAME "$PKGURL" "$VERSION"

