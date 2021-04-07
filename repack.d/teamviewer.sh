#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

if [ "$($DISTRVENDOR -a)" = "x86_64" ] ; then
    # 32 bit
    rm -fv $BUILDROOT/opt/teamviewer/tv_bin/script/libdepend
    subst "s|.*script/libdepend.*||" $SPEC
fi

# comment out libexo (we have libexo-gtk3 only now)
REQUIRES="xdg-utils,libdbus,libqt5-core,libqt5-dbus,libqt5-gui,libqt5-network,libqt5-qml,libqt5-quick,libqt5-webkit,libqt5-webkitwidgets,libqt5-widgets,libqt5-x11extras"
subst "s|^\(Name: .*\)$|# Converted from original package requires\nRequires:$REQUIRES\n\1|g" $SPEC

# TODO: check if we missed something from it
rm -rf $BUILDROOT/opt/teamviewer/tv_bin/script/teamviewer_setup

put_link()
{
    mkdir -p "$BUILDROOT$1"
    ln -sr "$BUILDROOT/opt/teamviewer/tv_bin/script/$2" "$BUILDROOT$1/$2"
}

TV_DBUS_FILE_GUI='com.teamviewer.TeamViewer.service'
TV_DBUS_FILE_DESKTOP='com.teamviewer.TeamViewer.Desktop.service'
TV_POLKIT_FILE='com.teamviewer.TeamViewer.policy'
#put_link /usr/share/dbus-1/services $TV_DBUS_FILE_GUI
#put_link /usr/share/dbus-1/services $TV_DBUS_FILE_DESKTOP
#put_link /usr/share/polkit-1/actions $TV_POLKIT_FILE
put_link /lib/systemd/system teamviewerd.service

subst "s|\"/opt/teamviewer/tv_bin/script/teamviewer_setup\"|\n\
/lib/systemd/system/teamviewerd.service\n\
|" $SPEC

#subst "s|\"/opt/teamviewer/tv_bin/script/teamviewer_setup\"|\n\
#/usr/share/dbus-1/services/$TV_DBUS_FILE_GUI\n\
#/usr/share/dbus-1/services/$TV_DBUS_FILE_DESKTOP\n\
#/usr/share/polkit-1/actions/$TV_POLKIT_FILE\n\
#/lib/systemd/system/teamviewerd.service\n\
#|" $SPEC

# don't use packed xdg-utils
rm -rfv $BUILDROOT/opt/teamviewer/tv_bin/xdg-utils
subst "s|.*/opt/teamviewer/tv_bin/xdg-utils.*||" $SPEC

rm -rfv $BUILDROOT/opt/teamviewer/tv_bin/script/teamviewerd.sysv
subst "s|.*/opt/teamviewer/tv_bin/script/teamviewerd.sysv.*||" $SPEC

# see https://bugzilla.altlinux.org/show_bug.cgi?id=39891
subst '1i%filter_from_requires /^\\/bin\\/ip/d' $SPEC
