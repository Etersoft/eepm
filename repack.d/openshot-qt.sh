#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=openshot-qt
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# AppImage bundles its own libFLAC (so.8), ignore the outdated soname requirement
ignore_lib_requires 'libFLAC.so.8'
# bundled Qt5, EGL and Wayland plugins not bundled (optional, X11 only)
ignore_lib_requires 'libQt5EglFSDeviceIntegration.so.*' 'libQt5WaylandClient.so.*'

# Optional PyQt modules and plugins reference these libraries, but OpenShot does
# not load them during normal operation. Do not pull system Qt for unused code.
ignore_lib_requires libQt5Network.so.5 libQt5PrintSupport.so.5

# AppRun crashes on current glibc; use OpenShot's bundled launcher directly.
add_bin_link_command $PRODUCT $PRODUCTDIR/usr/bin/openshot-qt-launch
