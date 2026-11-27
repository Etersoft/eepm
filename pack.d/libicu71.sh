#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# TAR is the Fedora 37 libicu RPM. Pull only the ICU 71 runtime shared libraries
# into usr/lib64. ALT's lib.prov does not auto-emit the soname provides for these
# files in the pack->repack flow, so the sonames are declared explicitly below.
mkdir -p usr/lib64
rpm2cpio "$TAR" | cpio -idmu --quiet './usr/lib64/libicu*.so.71*' 2>/dev/null

VERSION="71.1"

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME usr

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
group: System/Libraries
license: ICU
url: https://icu.unicode.org/
summary: ICU 71.1 runtime libraries (libicu*.so.71)
description: International Components for Unicode 71.1 runtime libraries, repacked from the Fedora 37 libicu RPM. Provides libicudata.so.71, libicui18n.so.71 and libicuuc.so.71 (plus libicutu/libicuio/libicutest) for apps built for RED OS 8 (Fedora 37), since ALT ships ICU >= 74.
# Declare the sonames explicitly: ALT's lib.prov only emits them for the
# SONAME-named symlink during rpmbuild, which the pack flow does not trigger
# reliably. Packages built for RED OS 8 require libicu*.so.71()(64bit).
provides: libicudata.so.71()(64bit) libicui18n.so.71()(64bit) libicuuc.so.71()(64bit) libicutu.so.71()(64bit) libicuio.so.71()(64bit) libicutest.so.71()(64bit)
EOF

return_tar $PKGNAME
