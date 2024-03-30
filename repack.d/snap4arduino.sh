#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=snap4arduino

. $(dirname $0)/common.sh

# TODO: move to json in pack.d
subst "s|^Group:.*|Group: Development/Other|" $SPEC
subst "s|^License: unknown$|License: AGPL-3.0|" $SPEC
subst "s|^URL:.*|URL: https://snap4arduino.rocks/|" $SPEC
subst "s|^Summary:.*|Summary: A modification of the Snap! visual programming language that lets you seamlessly interact with almost all versions of the Arduino board.|" $SPEC

add_bin_link_command $PRODUCT $PRODUCTDIR/run

# TODO: copy icons

cat <<EOF >$PRODUCT.desktop
[Desktop Entry]
Type=Application
Version=1.0
Icon=$PRODUCTDIR/icons/128x128x32.png
Exec=$PRODUCT
Name=Snap4Arduino
Name[en]=Snap4Arduino
GenericName[en]=Use Snap! to control Arduino boards. Arduino goes lambda!
EOF
install_file $PRODUCT.desktop /usr/share/applications/$PRODUCT.desktop

add_libs_requires
