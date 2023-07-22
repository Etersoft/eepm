#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTCUR=TeamSpeak
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Video|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: http://www.teamspeak.com|" $SPEC
subst "s|^Summary:.*|Summary: TeamSpeak is software for quality voice communication via the Internet|" $SPEC

add_bin_link_command $PRODUCTCUR $PRODUCTDIR/TeamSpeak
add_bin_link_command $PRODUCT $PRODUCTCUR

add_electron_deps
fix_chrome_sandbox

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Encoding=UTF-8
Name=TeamSpeak 5
GenericName=TeamSpeak 5 - Voice communication
Comment=TeamSpeak is software for quality voice communication via the Internet
Exec=teamspeak5
Icon=teamspeak5
StartupNotify=true
Terminal=false
Type=Application
Categories=Network;Application
StartupWMClass=TeamSpeak 5
EOF
pack_file /usr/share/applications/$PRODUCT.desktop

install_file .$PRODUCTDIR/logo-128.png /usr/share/pixmaps/$PRODUCT.png
