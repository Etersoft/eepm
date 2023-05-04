#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=commfort-client
PRODUCTDIR=/opt/eepm-wine/$PRODUCT

. $(dirname $0)/common.sh

subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

add_requires '/usr/bin/wine'

add_bin_link_command $PRODUCT $PRODUCTDIR/run.sh

mkdir -p usr/share/applications
cat <<EOF >usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=CommFort
Exec=$PRODUCT %F
Type=Application
StartupNotify=true
Icon=$PRODUCT
StartupWMClass=commfort.exe
Categories=Wine;Chat;Network;InstantMessaging;
EOF
pack_file /usr/share/applications/$PRODUCT.desktop

# copied from ~/.local/share/icons/hicolor/256x256/apps/2887_CommFort.0.png
i=256
install_file ipfs://QmaiWKRyPPSV4QeurB2sZabAv4RYuC5xsYqkBgPERNjZjJ /usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png
