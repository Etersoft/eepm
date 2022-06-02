#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Snap4Arduino
PRODUCTCUR=snap4arduino
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Development/Other|" $SPEC
subst "s|^License: unknown$|License: AGPL-3.0|" $SPEC
subst "s|^URL:.*|URL: http://snap4arduino.rocks/|" $SPEC
subst "s|^Summary:.*|Summary: A modification of the Snap! visual programming language that lets you seamlessly interact with almost all versions of the Arduino board.|" $SPEC

# move package to /opt
ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d))
mkdir $BUILDROOT/opt
mv $BUILDROOT/$ROOTDIR $BUILDROOT$PRODUCTDIR
subst "s|\"/$ROOTDIR/|\"$PRODUCTDIR/|" $SPEC

# add binary to the search path
mkdir -p $BUILDROOT/usr/bin/
ln -s $PRODUCTDIR/run $BUILDROOT/usr/bin/$PRODUCTCUR
subst "s|%files|%files\n/usr/bin/$PRODUCTUR|" $SPEC

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Type=Application
Version=1.0
Icon=$PRODUCTDIR/icons/128x128x32.png
Exec=$PRODUCTDIR/run
Name=Snap4Arduino
Name[en]=Snap4Arduino
GenericName[en]=Use Snap! to control Arduino boards. Arduino goes lambda!
EOF
subst "s|%files|%files\n/usr/share/applications/$PRODUCT.desktop|" $SPEC
