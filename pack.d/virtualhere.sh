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

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Remote access
license: GPLv2
url: https://virtualhere.com/usb_server_software
summary: Generic VirtualHere USB Server
description: Generic VirtualHere USB Server.
EOF

return_tar $PKGNAME.tar
