#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc -C opt/$PRODUCT unpack $TAR || fatal

VERSION="$(echo $TAR | sed -e 's|.*amd64-||' -e 's|\.tar\.bz2||')"
PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking
license: Proprietary
url: https://www.teamspeak.com
summary: TeamSpeak3 Server for Linux
description: TeamSpeak is software for quality voice communication via the Internet.
EOF

return_tar $PKGNAME.tar
