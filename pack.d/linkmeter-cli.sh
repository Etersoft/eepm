#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh


mkdir -p usr/bin

mv $TAR usr/bin/linkmeter-cli || fatal

chmod 755 usr/bin/linkmeter-cli

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar usr || fatal

return_tar $PKGNAME.tar
