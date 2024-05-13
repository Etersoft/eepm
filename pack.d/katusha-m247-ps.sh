#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

ROOTDIR=$(pwd)
# Linux-драйвер-печати-Катюша-M247.zip
erc unpack $TAR || fatal 
cd * # Linux драйвер печати Катюша M247

# 2021-02-23-Katusha_M247_x86_64_DEB.tar.gz
erc unpack *Katusha_M247_x86_64_DEB.tar.gz || fatal
rm *Katusha_M247_x86_64_DEB.tar.gz 
cd * # 2021-02-22-Katusha_M247_x86_64_DEB

# katusha-m247-ps_1.2.1_amd64.deb
PKGNAME=katusha-m247-ps_*_amd64.deb

# needed because the path contains spaces
mv $PKGNAME $ROOTDIR
cd $ROOTDIR

return_tar $PKGNAME
