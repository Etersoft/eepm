#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# workaround for Nvidia
fix_desktop_file "Exec=readest" "Exec=WEBKIT_DISABLE_DMABUF_RENDERER=1 readest"

# Fix empty License field from original package
subst "s|^License:.*|License: AGPL-3.0-or-later|" $SPEC
