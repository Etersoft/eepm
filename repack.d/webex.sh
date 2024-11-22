#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR='/opt/Webex'

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT $PRODUCTDIR/bin/CiscoCollabHost

move_file /opt/Webex/bin/webex.desktop /usr/share/applications/webex.desktop
move_file /opt/Webex/bin/sparklogosmall.png /usr/share/icons/hicolor/96x96/apps/webex.png

subst 's|^Exec=.*|Exec=webex %U|g' $BUILDROOT/usr/share/applications/webex.desktop
subst 's|^Icon=.*|Icon=webex.png|g' $BUILDROOT/usr/share/applications/webex.desktop

add_libs_requires