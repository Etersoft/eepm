#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=anydesk

mkdir -p $BUILDROOT/etc/systemd/system/
mv -fv $BUILDROOT/usr/share/anydesk/files/systemd/anydesk.service $BUILDROOT/etc/systemd/system/anydesk.service
subst "s|/usr/share/anydesk/files/systemd/anydesk.service|/etc/systemd/system/anydesk.service|g" $SPEC

mkdir -p $BUILDROOT/etc/rc.d/init.d/
mv -fv $BUILDROOT/usr/share/anydesk/files/init/anydesk $BUILDROOT/etc/rc.d/init.d/anydesk
subst "s|.*/etc/default/NetworkManager.*||" $BUILDROOT/etc/rc.d/init.d/anydesk
subst "s|/usr/share/anydesk/files/init/anydesk|/etc/rc.d/init.d/anydesk|" $SPEC

#subst '1iAutoProv:no' $SPEC
