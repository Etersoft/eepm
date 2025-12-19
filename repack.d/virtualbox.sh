#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=virtualbox
PRODUCTDIR=/opt/VirtualBox

. $(dirname $0)/common.sh

# conflict with the distro package
add_conflicts virtualbox VirtualBox

add_libs_requires
