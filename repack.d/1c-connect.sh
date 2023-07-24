#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# installing from tar, so we need fill some fields here
subst "s|^Group:.*|Group: Office|" $SPEC
subst "s|^License: unknown$|License: Proprietary|" $SPEC
subst "s|^URL:.*|URL: https://1c-connect.com/|" $SPEC
subst "s|^Summary:.*|Summary: 1C Connect|" $SPEC

add_bin_cdexec_command $PRODUCT $PRODUCTDIR/app/bin/connect

install_file $PRODUCTDIR/app/bin/ico-app.png /usr/share/pixmaps/$PRODUCT.png

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
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
pack_file /usr/share/applications/$PRODUCT.desktop

