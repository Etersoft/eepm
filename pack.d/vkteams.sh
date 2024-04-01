#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

if echo "$TAR" | grep -q "vkteams.tar.xz" ; then
    erc "$TAR" || fatal
else
    fatal "We support only vkteams.tar.xz"
fi

mkdir opt
mv vkteams* opt/$PRODUCT || fatal

PKG=$PRODUCT-$VERSION.tar
erc pack $PKG opt/$PRODUCT

cat <<EOF >$PKG.eepm.yaml
name: $PRODUCT
group: Networking/Instant messaging
license: Proprietary
url: https://teams.vk.com/
summary: VK Teams
description: VK Teams desktop client.
EOF

return_tar $PKG
