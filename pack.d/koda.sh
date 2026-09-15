#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# The download endpoint has a rolling "latest" filename. Rename it before
# generic-appimage extracts the image so the generated package is named koda.
RENAMED="koda.AppImage"
mv "$TAR" "$RENAMED" || fatal "Can't rename Koda AppImage"
exec "$(dirname "$0")/generic-appimage.sh" "$RENAMED" "$RETURNTARNAME" "$3" "$4"
