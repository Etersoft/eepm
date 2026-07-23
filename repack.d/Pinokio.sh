#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Pinokio
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

# Pinokio is shipped as a full Electron bundle with native helper binaries for
# several Linux targets; eepm's library scanner adds cross-arch/internal
# libraries and a huge Chromium dependency set that is not needed to repack
# the bundle.
stop_libs_requires

add_bin_link_command pinokio "$PRODUCTDIR/pinokio"
fix_desktop_file "$PRODUCTDIR/pinokio" pinokio

add_electron_deps
