#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=PrismLauncher-Linux
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

move_file /usr/share/pixmaps/PrismLauncher-Linux.svg /usr/share/icons/hicolor/scalable/apps/org.prismlauncher.PrismLauncher.svg

add_libs_requires
