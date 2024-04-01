#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

PRODUCT="snap4arduino"
# Snap4Arduino_desktop-gnu-64_9.1.1
PKG="$(basename "$TAR" | sed -e "s|Snap4Arduino_desktop-gnu-[36][24]\_|$PRODUCT-|")"

mkdir opt/
erc $TAR
mv -v Snap4Arduino* opt/$PRODUCT

erc a $PKG opt

cat <<EOF >$PKG.eepm.yaml
name: $PRODUCT
group: Development/Other
license: AGPL-3.0
url: https://snap4arduino.rocks/
summary: A modification of the Snap! visual programming language that lets you seamlessly interact with almost all versions of the Arduino board
description: A modification of the Snap! visual programming language that lets you seamlessly interact with almost all versions of the Arduino board.
EOF

return_tar $PKG
