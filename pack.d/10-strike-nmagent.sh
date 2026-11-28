#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# tar.gz contains 10-strike-nmagent-<version>.rpm and install.sh
erc --here unpack "$TAR" || fatal

PKG="$(find . -type f -name '10-strike-nmagent-*.rpm' | head -n1)"
[ -n "$PKG" ] || fatal "Can't find 10-strike-nmagent rpm in $TAR"

return_tar "$PKG"
