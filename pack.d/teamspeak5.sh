#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

[ "$(basename $TAR)" = "teamspeak-client.tar.gz" ] || fatal "Unsupported $TAR"

erc $TAR || fatal
mkdir -p opt
mv teamspeak-client.tar opt/TeamSpeak

PKGNAME=$PRODUCT-$VERSION

erc a $PKGNAME.tar opt/TeamSpeak

return_tar $PKGNAME.tar
