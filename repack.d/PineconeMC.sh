#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=PineconeMC
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

case $(epm print info -d) in
    Fedora)
        ignore_lib_requires 'libtiff.so.5*'
        ;;
esac

add_conflicts ElyPrismLauncher ElyPrismLauncher-Linux PrismLauncher prismlauncher
