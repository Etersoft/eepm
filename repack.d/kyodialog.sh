#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=kyodialog
# FIXME
VER=9.2
PRODUCTCUR=$PRODUCT$VER

. $(dirname $0)/common.sh

# embedded
filter_from_requires "python3(PyPDF3)"

set_autoreq 'yes'

# remove embedded PyPDF3
remove_dir /usr/share/kyocera$VER/Python

# PRIMARY_PPD_DIRECTORY=/usr/share/ppd/kyocera/
fromppd="/usr/share/kyocera$VER/ppd$VER"
mkdir -p $BUILDROOT/usr/share/ppd/
mv $BUILDROOT$fromppd $BUILDROOT/usr/share/ppd/kyocera
subst "s|$fromppd|/usr/share/ppd/kyocera|" $SPEC
pack_dir /usr/share/ppd/kyocera
#remove_dir $fromppd
#pack_file /usr/share/ppd/kyocera

# ALTERNATE_PPD_DIRECTORY=/usr/share/cups/model/kyocera
mkdir -p $BUILDROOT/usr/share/cups/model/
ln -s /usr/share/ppd/kyocera $BUILDROOT/usr/share/cups/model/kyocera
pack_file /usr/share/cups/model/kyocera

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCTCUR.desktop
[Desktop Entry]
Type=Application
Name=Kyocera Print Panel
Exec=$PRODUCTCUR
Icon=$PRODUCTCUR
Comment=Kyocera Print Panel
Terminal=false
Categories=Qt;Printing;HardwareSettings;Settings
EOF
pack_file /usr/share/applications/$PRODUCTCUR.desktop

install_file /usr/share/kyocera9.2/appicon_H.png /usr/share/pixmaps/$PRODUCTCUR.png
