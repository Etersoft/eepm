#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# AppImage bundles its own libFLAC (so.8), ignore the outdated soname requirement
ignore_lib_requires 'libFLAC.so.8'
# bundled Qt5, EGL and Wayland plugins not bundled (optional, X11 only)
ignore_lib_requires 'libQt5EglFSDeviceIntegration.so.*' 'libQt5WaylandClient.so.*'
