#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

# VMS-Pro64_SATVISION_Satvision-V.2.0_V2.15.0_250513_01.zip
erc unpack $TAR || fatal

# FIXME bug, it unpacks single file to subdir
mv "VMS "*/*.deb .

PKGNAME=satvision-v.2.0.deb
mv -v *.deb $PKGNAME

return_tar $PKGNAME
