#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# drop dictionaries from lib folder
move_to_opt "/usr/lib/Popcorn Time Nightly"

fix_desktop_file "Categories=" "Categories=Network;Video;"

# workaround for Nvidia
fix_desktop_file "Exec=popcorntime-tauri" "Exec=WEBKIT_DISABLE_DMABUF_RENDERER=1 GDK_BACKEND=x11 popcorntime-tauri"

add_libs_requires
