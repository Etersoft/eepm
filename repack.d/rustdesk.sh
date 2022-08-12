#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=rustdesk

. $(dirname $0)/common.sh

subst '1iAutoProv:no' $SPEC


# put service file to the normal place
mkdir -p $BUILDROOT/etc/systemd/system/
cp $BUILDROOT/usr/share/rustdesk/files/systemd/rustdesk.service $BUILDROOT/etc/systemd/system/$PRODUCT.service
remove_file /usr/share/rustdesk/files/systemd/rustdesk.service
pack_file /etc/systemd/system/$PRODUCT.service

# TODO
# if [[ "$parsedVersion" -gt "360" ]]; then
# sudo -H pip3 install pynput
remove_file /usr/share/rustdesk/files/pynput_service.py
# filter_from_requires "python3(pynput.*"

echo "Categories=GNOME;GTK;Network;RemoteAccess;" >> $BUILDROOT/usr/share/applications/$PRODUCT.desktop

epm install glib2 libcairo libgdk-pixbuf libgtk+3 libpango libpulseaudio libuuid libX11 libXau libxcb libXdmcp libXfixes libXtst xdotool
