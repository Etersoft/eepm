#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt /usr/lib/$PRODUCT
subst "s|^ExecStart=/usr/lib/$PRODUCT/$PRODUCT|ExecStart=$PRODUCTDIR/$PRODUCT|" "$BUILDROOT/usr/lib/systemd/system/$PRODUCT.service"
subst "s|^Categories.*|Categories=GNOME;GTK;Network;RemoteAccess;|" usr/share/applications/$PRODUCT.desktop
add_bin_link_command

add_unirequires curl
