#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/FreeTube

. $(dirname $0)/common.sh

remove_dir /usr/share/doc

add_bin_exec_command $PRODUCT

ignore_lib_requires 'libffmpeg.so()(64bit)'

add_electron_deps
