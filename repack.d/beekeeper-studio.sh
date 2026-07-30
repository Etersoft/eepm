#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=beekeeper-studio
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

move_dir "/opt/Beekeeper Studio" "$PRODUCTDIR"

remove_file /usr/bin/$PRODUCT
add_bin_link_command $PRODUCT "$PRODUCTDIR/$PRODUCT"
subst "s|^Exec=.*|Exec=$PRODUCT|" "$BUILDROOT"/usr/share/applications/*.desktop

# Beekeeper Studio is shipped as a full Electron bundle; generic ELF scanning
# adds bundled/internal library requires like libc.so()(64bit) on rpm systems.
stop_libs_requires

add_electron_deps
