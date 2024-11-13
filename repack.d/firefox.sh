#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"


. $(dirname $0)/common.sh

add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox
Comment=Fast and Private Web Browser
Exec=$PRODUCT %f
Icon=$PRODUCT
Terminal=false
StartupNotify=true
Categories=Networking;WWW
EOF

iconpath=$PRODUCTDIR/browser/chrome/icons/default/

iconname=$PRODUCT
for i in 16 32 48 64 128 ; do
    install_file $iconpath/default$i.png /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done
