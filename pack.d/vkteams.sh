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

ICONURL=https://is1-ssl.mzstatic.com/image/thumb/Purple122/v4/a8/36/64/a83664d6-9401-a8a4-c845-89e0c3ab0c89/icons-bundle.png/246x0w.png
install_file $ICONURL /usr/share/pixmaps/$PRODUCT.png

PKG=$PRODUCT-$VERSION.tar
erc pack $PKG opt/$PRODUCT usr

cat <<EOF >$PKG.eepm.yaml
name: $PRODUCT
group: Networking/Instant messaging
license: Proprietary
url: https://teams.vk.com/
summary: VK Teams
description: VK Teams desktop client.
EOF

return_tar $PKG
