#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTCUR=r7-organizer
PRODUCTDIR=/opt/r7-office/organizer

. $(dirname $0)/common.sh

add_conflicts r7organizer r7-organizer r7-office-organizer

iconname=r7-organizer

for i in 16 22 24 32 48 64 128 256; do
    install_file $PRODUCTDIR/chrome/icons/default/default$i.png /usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done

#install_file $PRODUCTDIR/r7-organizer.desktop /usr/share/applications/r7-organizer.desktop
move_file /usr/bin/r7organizer-wrapper /usr/bin/$PRODUCT
subst "s|/usr/bin/bash|/bin/bash|" $BUILDROOT/usr/bin/$PRODUCT

fix_desktop_file /usr/bin/r7organizer-wrapper $PRODUCT
add_bin_link_command $PRODUCTCUR $PRODUCT
add_bin_link_command r7organizer $PRODUCT

# TODO: set as default application: x-scheme-handler/r7-organizer=r7-organizer.desktop to /usr/share/applications/mimeapps.list

add_libs_requires
