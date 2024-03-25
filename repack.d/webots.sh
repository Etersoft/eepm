#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt "/usr/local/webots"

ignore_lib_requires librospack.so libtinyxml2.so.6 libicui18n.so.66 libicuuc.so.66  libbz2.so.1.0  libPocoFoundation.so.62
add_libs_requires

add_bin_link_command

fix_desktop_file "/usr/local/webots/resources/icons/core/webots.png"
