#!/bin/sh

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=XnView
[ -d "$BUILDROOT/opt/XnConvert" ] && PRODUCT=XnConvert
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# Upstream bundles Qt 6.8.9 but omits libQt6Pdf.so.6 and the private
# libQt6WaylandEglClientHwIntegration.so.6 library, so these plugins cannot
# load even from the original package. System Qt libraries may use another
# private ABI; remove the broken plugins and keep generic Wayland and XCB.
remove_file "$PRODUCTDIR/lib/imageformats/libqpdf.so"
remove_file "$PRODUCTDIR/lib/platforms/libqwayland-egl.so"
remove_file "$PRODUCTDIR/lib/wayland-graphics-integration-client/libqt-plugin-wayland-egl.so"
