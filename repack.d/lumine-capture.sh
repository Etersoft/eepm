#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# KWin matches the screenshot permission to the absolute executable path.
subst 's|^Exec=lumine-capture$|Exec=/usr/bin/lumine-capture|' "$BUILDROOT/usr/share/applications/lumine-capture.desktop"
