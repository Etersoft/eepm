#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/Citrix/NSGClient

. $(dirname $0)/common.sh


add_libs_requires
add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/NSGClient

install_file $PRODUCTDIR/bin/nsgclient.desktop /usr/share/applications/nsgclient.desktop
