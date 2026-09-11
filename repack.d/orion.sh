#!/bin/sh

BUILDROOT="$1"
SPEC="$2"
PRODUCT=orion

. $(dirname $0)/common.sh

# WebKit loads GLES with dlopen, so ELF dependency scanning cannot see it.
add_unirequires libGLESv2.so.2
# WebKit invokes these sandbox helpers by path rather than linking to them.
add_requires bubblewrap xdg-dbus-proxy

# This WebKit build ignores WEBKIT_EXEC_PATH. Use a short private path so
# replacing its compiled-in directory does not change the ELF layout.
WEBKIT_LIB="$BUILDROOT/opt/orion/lib64/libwebkitgtk-6.0.so.4"
[ -f "$WEBKIT_LIB" ] || fatal "Can't find Orion's WebKit library"
grep -aFq /app/libexec/webkitgtk-6.0 "$WEBKIT_LIB" ||
    grep -aFq /opt/orion/webkit "$WEBKIT_LIB" ||
    fatal "Can't find the WebKit process directory in Orion's library"
ln -snf libexec/webkitgtk-6.0 "$BUILDROOT/opt/orion/webkit" || fatal
pack_file /opt/orion/webkit
# Patch the real file: sed -i on the SONAME symlink would leave the other
# WebKit symlinks pointing at the unpatched library.
patch_binary "$(readlink -f "$WEBKIT_LIB")" /app/libexec/webkitgtk-6.0 /opt/orion/webkit || fatal
