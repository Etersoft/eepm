#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=r7draw-desktop
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# upstream uses /opt/Р7-Графика (non-ASCII dir name)
move_to_opt "/opt/Р7-Графика"

subst "s|^Exec=.*|Exec=$PRODUCT %U|" $BUILDROOT/usr/share/applications/$PRODUCT.desktop

add_bin_link_command

add_electron_deps
