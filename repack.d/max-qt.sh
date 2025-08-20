#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=max-qt
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_requires '/usr/bin/wine'

add_bin_link_command $PRODUCT $PRODUCTDIR/run.sh

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Max
Exec=$PRODUCT %F
Type=Application
StartupNotify=true
Icon=$PRODUCT
StartupWMClass=max.exe
Categories=Wine;Chat;Network;
EOF

i=256
install_file ipfs://QmSw1UzDAfrsZDYDAu4rzypeHFRyw5tvXh1JL2xHsmZZbZ /usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png
