#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

VERSION=$(grep "^Version:" $SPEC | sed -e "s|Version: ||")

case "$VERSION" in
    5* ) MAJORVERSION="5" ;;
    9*)  MAJORVERSION=$VERSION ;;
esac

PRODUCT=kyodialog
PRODUCTCUR=$PRODUCT$MAJORVERSION

. $(dirname $0)/common.sh

case "$VERSION" in
    5* )
        # rename to kyodialog-phase5 to distinguish from Phase 9
        subst "s|^Name:.*|Name: kyodialog-phase5|" $SPEC
        add_conflicts kyodialog
        ;;
    9*)
        add_conflicts kyodialog-phase5
        ;;
esac

# embedded
filter_from_requires "python3(PyPDF3)"

# Qt5 dependencies (system Qt, not bundled)
add_unirequires libQt5Core.so.5 libQt5DBus.so.5 libQt5Gui.so.5 libQt5Network.so.5 libQt5Widgets.so.5

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

# cups-driverd scans both /usr/share/cups/model and /usr/share/ppd, no symlink needed

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
