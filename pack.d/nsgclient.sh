#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc --here unpack $TAR || fatal

PKGNAME="$(echo SecureAccessClient_*_nsgclient*.deb)"

return_tar $PKGNAME
