#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

remove_dir "/opt/iitrust/gosuslugi_plugin/lib/cmake/"
remove_dir "/opt/iitrust/gosuslugi_plugin/lib/pkgconfig"

# 'libxcb-util.so.0()(64bit)'
remove_file "/opt/iitrust/gosuslugi_plugin/lib/libxcb-image.so.0*"
remove_file "/opt/iitrust/gosuslugi_plugin/lib/lib*.a"
remove_file "/opt/iitrust/gosuslugi_plugin/lib/lib*.la"
