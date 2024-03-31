#!/bin/sh

PKGNAME=element-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A feature-rich client for Matrix.org"
URL="https://element.io/"

. $(dirname $0)/common.sh

# https://packages.element.io/debian/pool/main/e/element-desktop/index.html
# https://packages.element.io/debian/pool/main/e/element-desktop/element-desktop_1.9.0_amd64.deb

arch="amd64"

mask="$(epm print constructname $PKGNAME "$VERSION" $arch "deb")"
PKGURL=$(eget --list --latest https://packages.element.io/debian/pool/main/e/element-desktop/index.html "$mask") || fatal "Can't get package URL"

install_pkgurl
