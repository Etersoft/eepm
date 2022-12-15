#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vkteams

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Networking/Instant messaging|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://teams.vk.com/|" $SPEC
subst "s|^Summary:.*|Summary: VK Teams|" $SPEC

# move package to /opt
mkdir -p $BUILDROOT$PRODUCTDIR
mv $BUILDROOT/* $BUILDROOT$PRODUCTDIR || fatal
subst "s|\"/|\"$PRODUCTDIR/|" $SPEC

add_bin_link_command $PRODUCT

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=VK Teams
Comment=Official desktop application for the VK Teams messaging service
Icon=$PRODUCT.png
Exec=vkteams -urlcommand %u
Categories=InstantMessaging;Social;Chat;Network;
Terminal=false
MimeType=x-scheme-handler/vkteams;x-scheme-handler/myteam-messenger;
Keywords=vkteams;
EOF

pack_file /usr/share/applications/$PRODUCT.desktop

ICONURL=https://is1-ssl.mzstatic.com/image/thumb/Purple122/v4/a8/36/64/a83664d6-9401-a8a4-c845-89e0c3ab0c89/icons-bundle.png/246x0w.png
mkdir -p $BUILDROOT/usr/share/pixmaps/
epm tool eget -O $BUILDROOT/usr/share/pixmaps/$PRODUCT.png $ICONURL
[ -s $BUILDROOT/usr/share/pixmaps/$PRODUCT.png ] && pack_file /usr/share/pixmaps/$PRODUCT.png || "echo Can't download icon for the program."
subst "s|.*$PRODUCTDIR/unittests.*||" $SPEC
