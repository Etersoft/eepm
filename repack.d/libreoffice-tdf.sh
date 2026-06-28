#!/bin/sh -x

# Repack fixups for the official LibreOffice build from The Document Foundation.

# It will run with: buildroot spec product pkg
BUILDROOT="$1"

. $(dirname $0)/common.sh

# Java integration loads libjawt from the JDK via JAVA_HOME at runtime; it is not on
# the loader path and no package provides the bare soname, so the require is spurious.
ignore_lib_requires libjawt.so

# The TDF-bundled Python links libxcrypt (libcrypt.so.2); ALT ships glibc libcrypt.so.1,
# which is ABI-compatible for crypt(). Ship a bundled compat symlink and drop the require.
ignore_lib_requires libcrypt.so.2
for progdir in "$BUILDROOT"/opt/libreoffice*/program ; do
    [ -d "$progdir" ] || continue
    ln -sf /usr/lib64/libcrypt.so.1 "$progdir/libcrypt.so.2"
done
