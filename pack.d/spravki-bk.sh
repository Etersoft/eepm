#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# Extract the archive
erc --here "$TAR" || fatal

# play.d selects a vendor archive containing one native package.
PKG=$(find . -type f \( -name "*.rpm" -o -name "*.deb" \) | head -1)
[ -n "$PKG" ] || fatal "Package file is not found in archive"

return_tar "$PKG"
