#!/bin/sh

PKGNAME=cascadeur
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Cascadeur - a physics‑based 3D animation software"

. $(dirname $0)/common.sh

page="$(eget -O- https://cascadeur.com/ru/download)"
BUILDID=$(echo "$page" | grep 'data-platform="linux"' | grep 'data-build-id=' | sed -e 's|.*data-build-id="\(.*\)" data-modal.*|\1|') #"
VERSION=$(echo "$page" | grep 'main-download__info-version' | sed -e 's|.*<div class="main-download__info-version">\(.*\)</div>.*|\1|') #"

# TODO: ask license, get version
epm pack --install $PKGNAME "https://cdn.cascadeur.com/builds/linux/$BUILDID/cascadeur-linux.tgz" "$VERSION"
