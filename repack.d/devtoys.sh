#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

install_file /opt/devtoys/devtoys/Icon-Windows-Linux-Preview.png /usr/share/icons/hicolor/512x512/apps/devtoys.png

fix_desktop_file /usr/bin/DevToys devtoys
fix_desktop_file /opt/devtoys/devtoys/Icon-Windows-Linux-Preview.png devtoys

add_libs_requires
