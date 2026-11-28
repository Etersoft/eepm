#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_bin_link_command

# The binary is packed (only libc is linked), these libraries are loaded at runtime
add_unirequires libX11.so.6 libXext.so.6 libXinerama.so.1 libXtst.so.6 libfontconfig.so.1
# libssl.so.1.1 or libssl.so.3 is also loaded (whichever is present), so no require for it
