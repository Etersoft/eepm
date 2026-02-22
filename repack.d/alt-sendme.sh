#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# Fix empty Categories
fix_desktop_file "Categories=" "Categories=GTK;FileTransfer;Utility;"

# workaround for Nvidia
# Gdk-Message: 18:22:11.766: Error 71 (Ошибка протокола) dispatching to Wayland display.
fix_desktop_file "Exec=alt-sendme" "Exec=WEBKIT_DISABLE_DMABUF_RENDERER=1 alt-sendme"

add_unirequires "libayatana-appindicator3.so.1()(64bit)"
