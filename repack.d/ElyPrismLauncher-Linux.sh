#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=ElyPrismLauncher-Linux
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

move_file /usr/share/pixmaps/ElyPrismLauncher-Linux.svg /usr/share/icons/hicolor/scalable/apps/org.prismlauncher.PrismLauncher.svg
add_conflicts PrismLauncher-Linux prismlauncher

