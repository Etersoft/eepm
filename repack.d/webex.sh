#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR='/opt/Webex'

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/CiscoCollabHost

move_file $PRODUCTDIR/bin/webex.desktop /usr/share/applications/webex.desktop
move_file $PRODUCTDIR/bin/sparklogosmall.png /usr/share/icons/hicolor/96x96/apps/webex.png

subst 's|^Exec=.*|Exec=webex %U|g' $BUILDROOT/usr/share/applications/webex.desktop
subst 's|^Icon=.*|Icon=webex.png|g' $BUILDROOT/usr/share/applications/webex.desktop

# from postinstall script
install_file .$PRODUCTDIR/bin/accessories/81-plugin-hidraw.rules /etc/udev/rules.d/81-plugin-hidraw.webex.rules
install_file .$PRODUCTDIR/bin/accessories/70-dsea.rules /etc/udev/rules.d/70-dsea.webex.rules

# linked with libtbb.so.2, but it is missed in the package's requirements
# it is used in such main libs as libinference_engine.so, so just build libtbb.so.2 for target system

