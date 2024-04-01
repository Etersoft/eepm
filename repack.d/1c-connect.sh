#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_cdexec_command $PRODUCT $PRODUCTDIR/app/bin/connect

install_file $PRODUCTDIR/app/bin/ico-app.png /usr/share/pixmaps/$PRODUCT.png

cat <<EOF |create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=1C Connect
Comment=1C Connect
Exec=$PRODUCT -- %u
Icon=$PRODUCT
Type=Application
Categories=Network;
X-GNOME-UsesNotifications=true
EOF
