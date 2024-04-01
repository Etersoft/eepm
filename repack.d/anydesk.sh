#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=anydesk

. $(dirname $0)/common.sh

remove_file /usr/share/anydesk/files/init/anydesk

# put service file to the normal place
install_file $BUILDROOT/usr/share/anydesk/files/systemd/anydesk.service /etc/systemd/system/anydesk.service
remove_file /usr/share/anydesk/files/systemd/anydesk.service

fix_desktop_file /usr/bin/$PRODUCT

add_libs_requires
