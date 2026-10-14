#!/bin/sh -x
# Runtime libraries loaded with dlopen by winit and the graphics backends.
# They are invisible to the ELF dependency scanner.
BUILDROOT="$1"
SPEC="$2"

UNIREQUIRES="libxkbcommon.so.0 libxkbcommon-x11.so.0
libX11.so.6 libXcursor.so.1 libXi.so.6 libXrandr.so.2
libvulkan.so.1 libEGL.so.1"

. $(dirname $0)/common.sh
