#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

ROOTDIR=$(pwd)

erc unpack $TAR || fatal
cd "Citrix_VPN"

PKGNAME="$(echo SecureAccessClient_*_nsgclient*.deb)"

# needed because the path contains spaces
mv $PKGNAME $ROOTDIR
cd $ROOTDIR

return_tar $PKGNAME
