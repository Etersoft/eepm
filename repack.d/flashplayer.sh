#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PREINSTALL_PACKAGES="glib2 libfontconfig1 libfreetype libgdk-pixbuf libGL libgtk+2 libnspr libnss libpango libX11 libXcursor libXrender"

. $(dirname $0)/common.sh

set_autoreq 'yes'

subst "s|^License: unknown$|License: Proprietary|" $SPEC
subst "s|^Summary:.*|Summary: Adobe Flash Player Standalone|" $SPEC

# from https://logos.fandom.com/wiki/Adobe_Flash_Player#2015%E2%80%932020
# https://static.wikia.nocookie.net/logopedia/images/7/7c/Flashplayer_app_RGB.svg/revision/latest/scale-to-width-down/200?cb=20190707103515
install_file "https://static.wikia.nocookie.net/logopedia/images/7/7c/Flashplayer_app_RGB.svg/revision/latest/scale-to-width-down/200?cb=20190707103515" /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Adobe Flash Player Standalone
Comment=Player for using content created on the Adobe Flash platform
Icon=$PRODUCT
Exec=$PRODUCT %u
Categories=Audio;AudioVideo;Graphics;GTK;Player;Video;Viewer;
MimeType=application/x-shockwave-flash;
Terminal=false
EOF

pack_file /usr/share/applications/$PRODUCT.desktop
