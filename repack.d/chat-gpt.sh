#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

UNIREQUIRES="libwebkit2gtk-4.0.so.37 libgtk-3.so.0 libgdk-3.so.0 libcairo.so.2 libgdk_pixbuf-2.0.so.0
libsoup-2.4.so.1 libgio-2.0.so.0 libjavascriptcoregtk-4.0.so.18
libgobject-2.0.so.0 libglib-2.0.so.0
libssl.so.3 libcrypto.so.3
libgcc_s.so.1 libm.so.6 libc.so.6"

. $(dirname $0)/common.sh

is_soname_present libssl.so.3 | fatal "This package needs OpenSSL 3."
