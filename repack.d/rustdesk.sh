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
remove_dir /usr/share/rustdesk/files/systemd
pack_file /etc/systemd/system/$PRODUCT.service


# TODO
# if [[ "$parsedVersion" -gt "360" ]]; then
# sudo -H pip3 install pynput
remove_file /usr/share/rustdesk/files/pynput_service.py
# filter_from_requires "python3(pynput.*"

subst "s|^Categories.*|Categories=GNOME;GTK;Network;RemoteAccess;|" $BUILDROOT/usr/share/applications/$PRODUCT.desktop
subst "s|/usr/share/rustdesk/files/rustdesk.png|$PRODUCT|" $BUILDROOT/usr/share/applications/$PRODUCT.desktop

ICONFILE=$PRODUCT.png
mkdir -p $BUILDROOT/usr/share/pixmaps/
cp $BUILDROOT/usr/share/rustdesk/files/rustdesk.png $BUILDROOT/usr/share/pixmaps/$ICONFILE
pack_file /usr/share/pixmaps/$ICONFILE

move_to_opt /usr/lib/rustdesk
add_bin_link_command

remove_dir /usr/lib

epm assure patchelf || fatal
for i in $BUILDROOT/$PRODUCTDIR/lib/*.so ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done

epm install glib2 libappindicator-gtk3 libcairo libgdk-pixbuf libgtk+3 libpango libpulseaudio libuuid libX11 libXau libxcb libXdmcp libXfixes libXtst xdotool

