#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# FreeCAD bundles its own Qt6/PySide6 but some libs link to unbundled Qt6 modules
# ignore all Qt6 dependencies — they are either bundled or optional
ignore_lib_requires 'libQt6.*'

# AppImage bundles system gtk3 icons that conflict with gtk3-demo package
for i in $BUILDROOT/usr/share/icons/hicolor/*/apps/gtk3-*.png ; do
    [ -f "$i" ] && remove_file "${i#$BUILDROOT}"
done
