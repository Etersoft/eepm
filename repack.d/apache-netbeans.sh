#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# foreign binaries in /usr/lib/apache-netbeans/ide/bin/nativeexecution
ignore_lib_requires libc.so.1 libjawt.so libpthread.1

# The bundled ZuluFX runtime may ship optional JavaFX media plugins for
# several ffmpeg ABIs at once. Supported systems don't provide this ABI
# set simultaneously, and the IDE itself does not need these plugins.
remove_file /usr/lib/apache-netbeans/jdk/lib/libavplugin-ffmpeg-*.so

# need openjdk to run
add_unirequires /usr/bin/javac
