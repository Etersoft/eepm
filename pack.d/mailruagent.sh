#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

if echo "$TAR" | grep -q "agent.tar.xz" ; then
    erc "$TAR" || fatal
else
    fatal "We support only agent.tar.xz"
fi

mkdir opt
mv agent* opt/$PRODUCT || fatal

# https://webagent.mail.ru/favicon.ico
install_file ipfs://QmZNK3w2i2CTUwfHfxiJR6HR2CDaALUUhJSq4bfoAEUMMH /usr/share/pixmaps/$PRODUCT.png

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME opt/$PRODUCT usr

cat <<EOF >$PKG.eepm.yaml
name: $PRODUCT
group: Networking/Instant messaging
license: Proprietary
url: https://agent.mail.ru/linux
summary: Mail.ru agent
description: Mail.ru agent.
EOF


return_tar $PKGNAME
