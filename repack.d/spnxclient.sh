#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst '1iAutoProv:no' $SPEC

subst '1iRequires: libpcsclite libudev0' $SPEC

if [ "$($DISTRVENDOR -a)" = "x86_64" ] ; then
    remove_file /usr/share/sphinx/gui/spnxreader/libspnxreader_i386.so
    remove_file /usr/share/sphinx/gui/lib/libguinative_i386.so
    subst "s|/usr/lib/i386-linux-gnu/libpcsclite.so|/usr/lib64/libpcsclite.so|" $BUILDROOT/usr/bin/spnxclient
else
    remove_file /usr/share/sphinx/gui/spnxreader/libspnxreader_amd64.so
    remove_file /usr/share/sphinx/gui/lib/libguinative_amd64.so
    subst "s|/usr/lib/i386-linux-gnu/libpcsclite.so|/usr/lib/libpcsclite.so|" $BUILDROOT/usr/bin/spnxclient
fi

# https://sigur.com/download/
echo "WARNING! Just see these crazy pre/post install scripts in the original deb package."
exit 1
