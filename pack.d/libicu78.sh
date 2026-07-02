#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# TAR is the Fedora 45 libicu RPM. Pull only the ICU 78 runtime shared libraries
# into usr/lib64. ALT's lib.prov does not auto-emit the soname provides for these
# files in the pack->repack flow, so the sonames are declared explicitly below.
mkdir -p usr/lib64
rpm2cpio "$TAR" | cpio -idmu --quiet './usr/lib64/libicu*.so.78*' 2>/dev/null

VERSION="78.3"

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME usr

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
group: System/Libraries
license: ICU
url: https://icu.unicode.org/
summary: ICU 78.3 runtime libraries (libicu*.so.78)
description: International Components for Unicode 78.3 runtime libraries, repacked from the Fedora 45 libicu RPM. Provides libicudata.so.78, libicui18n.so.78 and libicuuc.so.78 (plus libicutu/libicuio/libicutest) for apps built against Fedora 45, since ALT ships ICU <= 74.
# Declare the sonames explicitly: ALT's lib.prov only emits them for the
# SONAME-named symlink during rpmbuild, which the pack flow does not trigger
# reliably. Packages built against Fedora 45 require libicu*.so.78()(64bit).
provides: libicudata.so.78()(64bit) libicui18n.so.78()(64bit) libicuuc.so.78()(64bit) libicutu.so.78()(64bit) libicuio.so.78()(64bit) libicutest.so.78()(64bit)
EOF

return_tar $PKGNAME
