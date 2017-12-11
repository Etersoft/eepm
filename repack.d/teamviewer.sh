#!/bin/sh -x

# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

if [ "$(distr_info -a)" = "x86_64" ] ; then
    # 32 bit
    rm -fv $BUILDROOT/opt/teamviewer/tv_bin/script/libdepend
    subst "s|.*script/libdepend.*||" $SPEC
fi

REQUIRES="libdbus,libexo,libqt5-core,libqt5-dbus,libqt5-gui,libqt5-network,libqt5-qml,libqt5-quick,libqt5-webkit,libqt5-webkitwidgets,libqt5-widgets,libqt5-x11extras"
subst "s|^\(Name: .*\)$|# Converted from original package requires\nRequires:$REQUIRES\n\1|g" $SPEC
