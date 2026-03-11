#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# install desktop files (originals are in files/ subdir, postinstall copies them)
install_file usr/share/bitdesk/files/bitdesk.desktop /usr/share/applications/$PRODUCT.desktop
install_file usr/share/bitdesk/files/bitdesk-link.desktop /usr/share/applications/$PRODUCT-link.desktop

# put service file to the normal place
install_file usr/share/bitdesk/files/bitdesk.service /etc/systemd/system/$PRODUCT.service

# remove files/ dir (contents already installed above)
remove_dir /usr/share/bitdesk/files

move_to_opt /usr/share/bitdesk

subst "s|^Categories.*|Categories=GNOME;GTK;Network;RemoteAccess;|" usr/share/applications/$PRODUCT.desktop

add_bin_link_command

add_unirequires curl
