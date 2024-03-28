#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

echo "$TAR" | grep -q "1C-Connect-Linux-x64.tar.gz" || fatal "Use only for 1C-Connect-Linux-x64.tar.gz."

mkdir opt
erc unpack $TAR || fatal
mv 1C-Connect-Linux-x64* opt/$PRODUCT

echo "true" > ./opt/$PRODUCT/app/bin/updater

VERSION="$(grep version_name opt/$PRODUCT/dist.json | sed -e 's|",.*||' -e 's|.*"||')"
[ -n "$VERSION" ] || fatal "Can't get version from dist.json file."

PKGNAME=$PRODUCT-$VERSION

erc a $PKGNAME.tar opt

return_tar $PKGNAME.tar
