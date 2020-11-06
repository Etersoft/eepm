#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=anydesk

mkdir -p $BUILDROOT/etc/systemd/system
ln -sf /usr/share/anydesk/files/systemd/anydesk.service $BUILDROOT/etc/systemd/system/anydesk.service
subst "s|/usr/share/anydesk/files/systemd/anydesk.service|/etc/systemd/system/anydesk.service|g" $SPEC

#subst '1iAutoProv:no' $SPEC
