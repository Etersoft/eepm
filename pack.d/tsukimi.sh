#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"

. $(dirname $0)/common.sh

VERSION=$(echo "$URL" | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+')
[ -n "$VERSION" ] || fatal "Can't get package version"
# use version from tarball
# (TODO: get basename via erc
PKGNAME="$(basename $TAR .tar.gz | sed -e "s|-x86_64-linux-gnu||")"
PKGNAME=$PRODUCT-$VERSION

mkdir -p opt/
erc unpack $TAR || fatal
mv $PRODUCT* opt/$PRODUCT

erc pack $PKGNAME.tar opt || fatal

return_tar $PKGNAME.tar
