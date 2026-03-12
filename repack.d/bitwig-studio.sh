#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

ignore_lib_requires 'libgif.so.7()(64bit)' 'libnet.so()(64bit)' 'libjvm.so()(64bit)' 'libjli.so()(64bit)' \
'libjava.so()(64bit)' 'libawt_xawt.so()(64bit)' 'libawt.so()(64bit)'

# BitwigPluginHost-X86-SSE41 is a 32-bit binary for running 32-bit VST plugins
# ignore its deps to avoid pulling i586 packages
ignore_lib_requires 'libm.so.6' 'libxcb-icccm.so.4' 'libxcb-util.so.1' 'libxcb.so.1' \
'libxkbcommon.so.0' 'libX11.so.6' 'libatomic.so.1' 'libc.so.6' 'ld-linux.so.2'

