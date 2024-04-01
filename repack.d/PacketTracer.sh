#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=packettracer
PRODUCTDIR=/opt/pt

. $(dirname $0)/common.sh

# reenable console output
subst 's| > /dev/null 2>&1||' opt/pt/packettracer

#add_requires sudo dialog xdg-utils

add_libs_requires

if -d usr/share/applications ; then
    fix_desktop_file
else
    echo -e "[Desktop Entry]\nType=Application\nExec=/opt/pt/packettracer %f\nName=Packet Tracer\nIcon=/opt/pt/art/app.png\nTerminal=false\nStartupNotify=true\nMimeType=application/x-pkt;application/x-pka;application/x-pkz;application/x-pks;application/x-pksz;"  \
        | create_file /usr/share/applications/cisco-pt.desktop
    echo -e "[Desktop Entry]\nType=Application\nExec=/opt/pt/packettracer -uri=%u\nName=Packet Tracer\nIcon=/opt/pt/art/app.png\nTerminal=false\nStartupNotify=true\nNoDisplay=true\nMimeType=x-scheme-handler/pttp;" \
        | create_file /usr/share/applications/cisco-ptsa.desktop
fi

add_bin_link_command

for i in icudtl.dat  qtwebengine_devtools_resources.pak  qtwebengine_resources_100p.pak  qtwebengine_resources_200p.pak  qtwebengine_resources.pak ; do
    install_file opt/pt/bin/$i /opt/pt/bin/resources/$i
    remove_file /opt/pt/bin/$i
done

remove_dir /opt/pt/bin/qtwebengine_locales
ln -s /opt/pt/translations opt/pt/bin/translations
pack_file /opt/pt/bin/translations

# TODO
#Icon=/opt/pt/art/app.png

# TODO
#CONTENTS.cpio/ucpio://usr/share/icons/gnome/48x48/mimetypes
#/usr/share/icons/hicolor/48x48/mimetypes


