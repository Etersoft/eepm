#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/r7-office

. $(dirname $0)/common.sh

fix_desktop_file /usr/bin/r7-office-desktopeditors
fix_desktop_file /usr/bin/r7-office-imageviewer
fix_desktop_file /usr/bin/r7-office-videoplayer

# libQt5EglFSDeviceIntegration.so.5()(64bit)
remove_file $PRODUCTDIR/desktopeditors/platforms/libqeglfs.so
remove_file $PRODUCTDIR/mediaviewer/platforms/libqeglfs.so

# libQt5Qml.so.5()(64bit)
# libQt5VirtualKeyboard.so.5()(64bit)
remove_file $PRODUCTDIR/desktopeditors/platforminputcontexts/libqtvirtualkeyboardplugin.so
remove_file $PRODUCTDIR/mediaviewer/platforminputcontexts/libqtvirtualkeyboardplugin.so

# libQt5Quick.so.5()(64bit)
remove_file $PRODUCTDIR/desktopeditors/platforms/libqwebgl.so
remove_file $PRODUCTDIR/mediaviewer/platforms/libqwebgl.so

# libQt5WaylandClient.so.5()(64bit)
remove_file $PRODUCTDIR/desktopeditors/platforms/libqwayland-egl.so
remove_file $PRODUCTDIR/desktopeditors/platforms/libqwayland-generic.so
remove_file $PRODUCTDIR/desktopeditors/platforms/libqwayland-xcomposite-egl.so
remove_file $PRODUCTDIR/desktopeditors/platforms/libqwayland-xcomposite-glx.so
remove_file $PRODUCTDIR/mediaviewer/platforms/libqwayland-egl.so
remove_file $PRODUCTDIR/mediaviewer/platforms/libqwayland-generic.so
remove_file $PRODUCTDIR/mediaviewer/platforms/libqwayland-xcomposite-egl.so
remove_file $PRODUCTDIR/mediaviewer/platforms/libqwayland-xcomposite-glx.so

