#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/davinci-resolve

. $(dirname $0)/common.sh

add_conflicts davinci-resolve

ignore_lib_requires libstdc++-libc6.2-2.so.3 libstdc++.so.5

add_libs_requires

add_bin_exec_command davinci-resolve "$PRODUCTDIR/bin/resolve"
add_bin_exec_command blackmagicrawplayer "$PRODUCTDIR/BlackmagicRAWPlayer/BlackmagicRAWPlayer"
add_bin_exec_command blackmagicrawspeedtest "$PRODUCTDIR/BlackmagicRAWSpeedTest/BlackmagicRAWSpeedTest"
add_bin_exec_command davinci_control_panels_setup "$PRODUCTDIR/DaVinci Control Panels Setup/DaVinci Control Panels Setup"
