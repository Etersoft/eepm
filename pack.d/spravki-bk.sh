#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# Extract the archive
erc "$TAR" || fatal

# Find the deb file in extracted content
PKG=$(find . -name "*.deb" -type f | head -1)

if [ -z "$PKG" ]; then
    fatal "DEB file is not found in archive"
fi

return_tar "$PKG"
