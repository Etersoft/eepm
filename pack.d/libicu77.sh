#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# TAR is the Fedora 43 libicu RPM. Pull only the ICU 77 runtime shared libraries
# into usr/lib64. ALT's lib.prov does not auto-emit the soname provides for these
# files in the pack->repack flow, so the sonames are declared explicitly below.
mkdir -p usr/lib64
rpm2cpio "$TAR" | cpio -idmu --quiet './usr/lib64/libicu*.so.77*' 2>/dev/null

VERSION="77.1"

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME usr

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
group: System/Libraries
license: ICU
url: https://icu.unicode.org/
summary: ICU 77.1 runtime libraries (libicu*.so.77)
description: International Components for Unicode 77.1 runtime libraries, repacked from the Fedora 43 libicu RPM. Provides libicudata.so.77, libicui18n.so.77 and libicuuc.so.77 (plus libicutu/libicuio/libicutest) for apps built against the GNOME 49 runtime, since ALT ships ICU <= 76.
# Declare the sonames explicitly: ALT's lib.prov only emits them for the
# SONAME-named symlink during rpmbuild, which the pack flow does not trigger
# reliably. Packages built against GNOME 49 require libicu*.so.77()(64bit).
provides: libicudata.so.77()(64bit) libicui18n.so.77()(64bit) libicuuc.so.77()(64bit) libicutu.so.77()(64bit) libicuio.so.77()(64bit) libicutest.so.77()(64bit)
EOF

return_tar $PKGNAME
