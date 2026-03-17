#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# Fix broken Categories
fix_desktop_file "Categories=.*" "Categories=Network;InstantMessaging;Chat;"

# Drop no sandbox from exec (Lenza --no-sandbox %U)
fix_desktop_file "Exec=.*" "Exec=lenza %U"
