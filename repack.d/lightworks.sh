#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

#PRODUCT=lightworks

# lib.req: ERROR: /tmp/.private/.../usr/lib/lightworks/libirng.so: no symbol bindings
subst '1i%add_findreq_skiplist /usr/lib/lightworks/libirng.so /usr/lib/lightworks/libsvml.so' $SPEC

set_autoreq 'yes'

# ignore embedded libs
for i in libc++.so.1 libc++abi.so.1 libedit.so libportaudio.so.2 libportaudiocpp.so.0 ; do
    subst "1i%filter_from_requires /^$i()(64bit).*/d" $SPEC
done

echo "Note: Download and install rpm package from https://developer.nvidia.com/cg-toolkit-download"
