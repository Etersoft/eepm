#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

UNIREQUIRES="udev libusb-1.0.so.0"

. $(dirname $0)/common.sh

add_qt5_deps

exit

if epm assure patchelf ; then
for i in usr/lib64/epsonscan2/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done
fi

set_autoreq 'yes'
