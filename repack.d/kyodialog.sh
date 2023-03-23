#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst '1iRequires: python3-module-PyPDF3' $SPEC

subst '1iAutoProv: no' $SPEC

VER=9.2
# remove embedded PyPDF3
remove_dir /usr/share/kyocera$VER/Python

# PRIMARY_PPD_DIRECTORY=/usr/share/ppd/kyocera/
fromppd="/usr/share/kyocera$VER/ppd$VER"
mkdir -p $BUILDROOT/usr/share/ppd/
mv $BUILDROOT$fromppd $BUILDROOT/usr/share/ppd/kyocera
subst "s|$fromppd|/usr/share/ppd/kyocera|" $SPEC
pack_dir /usr/share/ppd/kyocera
#remove_dir $fromppd
#pack_file /usr/share/ppd/kyocera

# ALTERNATE_PPD_DIRECTORY=/usr/share/cups/model/kyocera
mkdir -p $BUILDROOT/usr/share/cups/model/
ln -s /usr/share/ppd/kyocera $BUILDROOT/usr/share/cups/model/kyocera
pack_file /usr/share/cups/model/kyocera
