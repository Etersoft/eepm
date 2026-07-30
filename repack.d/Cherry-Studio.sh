#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Cherry-Studio
PRODUCTCUR=CherryStudio
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

subst "s|^Name:.*|Name: $PRODUCT|" "$SPEC"

move_dir "/opt/Cherry Studio" "$PRODUCTDIR"

remove_file /usr/bin/$PRODUCTCUR
add_bin_link_command $PRODUCTCUR "$PRODUCTDIR/$PRODUCTCUR"
add_bin_link_command $PRODUCT $PRODUCTCUR
subst "s|^Exec=.*|Exec=$PRODUCTCUR|" "$BUILDROOT"/usr/share/applications/*.desktop

# Cherry Studio is shipped as a full Electron bundle; generic ELF scanning adds
# bundled/internal library requires like libc.so()(64bit) on rpm systems.
stop_libs_requires

add_electron_deps
