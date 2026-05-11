#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# Fix empty License field from original package
subst "s|^License:.*|License: Apache-2.0|" $SPEC

# workaround for Nvidia
# Gdk-Message: 18:22:11.766: Error 71 (Ошибка протокола) dispatching to Wayland display.
fix_desktop_file "Exec=terax" "Exec=WEBKIT_DISABLE_DMABUF_RENDERER=1 terax"

