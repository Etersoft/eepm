#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

mkdir -p opt/$PRODUCT

erc $TAR || fatal

mv WinBox_Linux/* opt/$PRODUCT

VERSION=$(echo "$URL" | awk -F'/' '{print $6}')
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt || fatal

return_tar $PKGNAME.tar
