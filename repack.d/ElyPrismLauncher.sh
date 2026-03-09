#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=ElyPrismLauncher
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_obsoletes ElyPrismLauncher-Linux
add_conflicts PrismLauncher prismlauncher

