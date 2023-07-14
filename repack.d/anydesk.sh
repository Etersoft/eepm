#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=anydesk

# install all requires packages before packing (the list have got with rpmreqs anydesk)
#PREINSTALL_PACKAGES="fontconfig glib2 libatk libcairo libfreetype libgdk-pixbuf libgio libGL libGLU libgtk+2 libICE libpango libpolkit libSM libX11 libxcb libXdamage libXext libXfixes libXi libxkbfile libXmu libXrandr libXrender libXt libXtst polkit libminizip libgtkglext libpangox-1.0.so.0"
UNIREQUIRES="libGL.so.1 libGLU.so.1 libX11-xcb.so.1 libX11.so.6 libXdamage.so.1 libXext.so.6 libXfixes.so.3 libXi.so.6 libXrandr.so.2 libXrender.so.1 libXtst.so.6 libatk-1.0.so.0
libcairo.so.2 libfontconfig.so.1 libfreetype.so.6
libgdk-x11-2.0.so.0 libgdk_pixbuf-2.0.so.0 libgio-2.0.so.0 libglib-2.0.so.0 libgobject-2.0.so.0 libgtk-x11-2.0.so.0 libpango-1.0.so.0 libpangocairo-1.0.so.0 libpangoft2-1.0.so.0 libpolkit-gobject-1.so.0
libstdc++.so.6
libxcb-shm.so.0 libxcb.so.1 libxkbfile.so.1
polkit"

. $(dirname $0)/common.sh

#mkdir -p $BUILDROOT/etc/systemd/system/
#mv -fv $BUILDROOT/usr/share/anydesk/files/systemd/anydesk.service $BUILDROOT/etc/systemd/system/anydesk.service
#subst "s|/usr/share/anydesk/files/systemd/anydesk.service|/etc/systemd/system/anydesk.service|g" $SPEC

#mkdir -p $BUILDROOT/etc/rc.d/init.d/
#mv -fv $BUILDROOT/usr/share/anydesk/files/init/anydesk $BUILDROOT/etc/rc.d/init.d/anydesk
#subst "s|.*/etc/default/NetworkManager.*||" $BUILDROOT/etc/rc.d/init.d/anydesk
#subst "s|/usr/share/anydesk/files/init/anydesk|/etc/rc.d/init.d/anydesk|" $SPEC

remove_file /usr/share/anydesk/files/init/anydesk

# put service file to the normal place
mkdir -p $BUILDROOT/etc/systemd/system/
cp $BUILDROOT/usr/share/anydesk/files/systemd/anydesk.service $BUILDROOT/etc/systemd/system/anydesk.service
remove_file /usr/share/anydesk/files/systemd/anydesk.service
pack_file /etc/systemd/system/anydesk.service

fix_desktop_file /usr/bin/$PRODUCT

# autoreq is disabled, skip elf patching due requires
exit

LIBDIR=/usr/lib64
[ -d $BUILDROOT$LIBDIR ] || LIBDIR=/usr/lib

# don't check lib if missed
[ ! -d $BUILDROOT$LIBDIR ] && exit

if epm assure patchelf ; then
for i in $BUILDROOT$LIBDIR/anydesk/{libgdkglext-x11-1.0.*,libgtkglext-x11-1.0.*} ; do
    a= patchelf --set-rpath '$ORIGIN/' $i
done

# /usr/libexec/anydesk: library libpangox-1.0.so.0 not found
for i in $BUILDROOT/usr/libexec/anydesk ; do
    a= patchelf --set-rpath "$LIBDIR/anydesk" $i
done
fi

# preloaded from /usr/lib64/anydesk/, drop external requires
filter_from_requires libpangox-1.0.so.0 libgdkglext-x11-1.0.so.0 libgtkglext-x11-1.0.so.0

#add_requires $PREINSTALL_PACKAGES
#set_autoreq 'yes'
