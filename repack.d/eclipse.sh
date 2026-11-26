#!/bin/sh -x
# It will run with two args: buildroot spec
# Common repack script for all Eclipse IDE editions (eclipse-<edition>.sh are symlinks)
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# SWT loads GTK 3 with dlopen, so the soname scanner does not see it
add_unirequires libgtk-3.so.0

# the bundled JRE loads fontconfig with dlopen (AWT/Java2D, used by SWT SVG icons)
add_unirequires libfontconfig.so.1

# SWT Browser (Welcome, Javadoc hovers, Oomph notifications) loads WebKitGTK with dlopen
add_unirequires libwebkit2gtk-4.1.so.0
