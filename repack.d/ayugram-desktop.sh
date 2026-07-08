#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=ayugram-desktop

. $(dirname $0)/common.sh

# replace old package name
add_conflicts ayugram
add_obsoletes ayugram

# /usr/bin/AyuGram already in package, add lowercase alias
add_bin_link_command ayugram AyuGram

# Arch binary dynamically links Qt and other libs — add them as forced requires
# (reqstoplist blocks libQt6*, so we need add_unirequires to mark them as forced)
stop_libs_requires
add_unirequires $(epm req --short "$BUILDROOT/usr/bin/AyuGram" 2>/dev/null)

