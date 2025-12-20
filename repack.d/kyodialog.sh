#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

VERSION=$(grep "^Version:" $SPEC | sed -e "s|Version: ||")

case "$VERSION" in
    # set MAJORVERSION to "5" to ensure the correct version is used in the path
    5* )
        MAJORVERSION="5"
        ;;
    9*)
        MAJORVERSION=$VERSION
esac

PRODUCT=kyodialog
PRODUCTCUR=$PRODUCT$MAJORVERSION

. $(dirname $0)/common.sh

# embedded
filter_from_requires "python3(PyPDF3)"


# remove embedded PyPDF3
remove_dir /usr/share/kyocera$MAJORVERSION/Python

# PRIMARY_PPD_DIRECTORY=/usr/share/ppd/kyocera/
fromppd="/usr/share/kyocera$MAJORVERSION/ppd$MAJORVERSION"
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

cat <<EOF |create_file /usr/share/applications/$PRODUCTCUR.desktop
[Desktop Entry]
Type=Application
Name=Kyocera Print Panel
Exec=$PRODUCTCUR
Icon=$PRODUCTCUR
Comment=Kyocera Print Panel
Terminal=false
Categories=Qt;Printing;HardwareSettings;Settings
EOF

# 9.3 appicon_H.png; 5.0 appicon_F.png 
install_file "/usr/share/kyocera$MAJORVERSION/appicon_H.png" "/usr/share/pixmaps/$PRODUCTCUR.png" || install_file "/usr/share/kyocera$MAJORVERSION/appicon_F.png" "/usr/share/pixmaps/$PRODUCTCUR.png" 
