#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

BINNAME=vhusbd
PRODUCT=virtualhere
PKGNAME=$PRODUCT-$VERSION

# https://github.com/virtualhere/script/blob/main/install_server
install -m0755 -D "$TAR" opt/$PRODUCT/$BINNAME || fatal

erc a $PKGNAME.tar opt

return_tar $PKGNAME.tar
