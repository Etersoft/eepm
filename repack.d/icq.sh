#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=icq
PRODUCTCUR=icq

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Networking/Instant messaging|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://www.jetbrains.com/pycharm|" $SPEC
subst "s|^Summary:.*|Summary: The Python IDE for Professional Developers|" $SPEC

# move package to /opt
mkdir -p $BUILDROOT$PRODUCTDIR
mv $BUILDROOT/{icq,qt.conf,lib,QtQuick.2,QtQuick,plugins} $BUILDROOT$PRODUCTDIR || fatal
subst "s|\"/|\"$PRODUCTDIR/|" $SPEC

add_bin_link_command $PRODUCT

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=ICQ for Linux
Comment=Simple way to communicate and nothing extra. New design, group chats and much more!
Icon=icq.png
Exec=icq -urlcommand %u
Categories=InstantMessaging;Social;Chat;Network;
Terminal=false
MimeType=x-scheme-handler/icq;
Keywords=icq;
EOF

pack_file /usr/share/applications/$PRODUCT.desktop

mkdir -p $BUILDROOT/usr/share/pixmaps/
eget -O $BUILDROOT/usr/share/pixmaps/$PRODUCT.png https://res.cloudinary.com/canonical/image/fetch/f_auto,q_auto,fl_sanitize,w_60,h_60/https://dashboard.snapcraft.io/site_media/appmedia/2020/04/icq_copy.png
pack_file /usr/share/pixmaps/$PRODUCT.png
subst "s|.*/opt/icq/unittests.*||" $SPEC
