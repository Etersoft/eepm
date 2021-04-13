#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=anydesk

#mkdir -p $BUILDROOT/etc/systemd/system/
#mv -fv $BUILDROOT/usr/share/anydesk/files/systemd/anydesk.service $BUILDROOT/etc/systemd/system/anydesk.service
#subst "s|/usr/share/anydesk/files/systemd/anydesk.service|/etc/systemd/system/anydesk.service|g" $SPEC

#mkdir -p $BUILDROOT/etc/rc.d/init.d/
#mv -fv $BUILDROOT/usr/share/anydesk/files/init/anydesk $BUILDROOT/etc/rc.d/init.d/anydesk
#subst "s|.*/etc/default/NetworkManager.*||" $BUILDROOT/etc/rc.d/init.d/anydesk
#subst "s|/usr/share/anydesk/files/init/anydesk|/etc/rc.d/init.d/anydesk|" $SPEC

# install all requires packages before packing (the list have got with rpmreqs anydesk)
epm install --skip-installed fontconfig glib2 libatk libcairo libfreetype libgdk-pixbuf libgio libGL libGLU libgtk+2 libICE libpango libpolkit \
    libSM libX11 libxcb libXdamage libXext libXfixes libXi libxkbfile libXmu libXrandr libXrender libXt libXtst polkit

#subst '1iAutoProv:no' $SPEC

# preloaded from /usr/lib64/anydesk/, drop external requires
subst '1i%filter_from_requires /^libpangox-1.0.so.0.*/d' $SPEC
subst '1i%filter_from_requires /^libgdkglext-x11-1.0.so.0.*/d' $SPEC
subst '1i%filter_from_requires /^libgtkglext-x11-1.0.so.0.*/d' $SPEC
