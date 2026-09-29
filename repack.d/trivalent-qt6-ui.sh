#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/trivalent

. $(dirname $0)/common.sh

move_to_opt /usr/lib64/trivalent
ignore_lib_requires libQt6Core.so.6 libQt6Gui.so.6 libQt6Widgets.so.6
add_requires trivalent
