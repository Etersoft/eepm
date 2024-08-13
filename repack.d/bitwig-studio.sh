#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

ignore_lib_requires 'libgif.so.7()(64bit)' 'libnet.so()(64bit)' 'libjvm.so()(64bit)' 'libjli.so()(64bit)' \
'libjava.so()(64bit)' 'libawt_xawt.so()(64bit)' 'libawt.so()(64bit)'

add_libs_requires 
