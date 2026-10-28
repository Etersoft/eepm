#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-ascon-kompas.sh

# postinst of the package creates the command link
add_bin_link_command kompas-study-v25 /opt/ascon/kompas3d-v25/Bin/kStudy
