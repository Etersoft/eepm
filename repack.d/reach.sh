#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# Fix empty Categories
fix_desktop_file "Categories=" "Categories=GTK;FileTransfer;Utility;"

add_unirequires "libayatana-appindicator3.so.1()(64bit)"
