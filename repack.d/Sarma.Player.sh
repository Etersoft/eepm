#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Sarma.Player
PRODUCTDIR=/opt/Sarma.Player

. $(dirname $0)/common.sh

move_to_opt /usr/share/$PRODUCT

# used only by the original maintainer scripts
remove_file $PRODUCTDIR/copy.sh
remove_file $PRODUCTDIR/del.sh

# the desktop file was copied to /usr/share/applications by the original %post
move_file $PRODUCTDIR/sarma.player.desktop /usr/share/applications/sarma.player.desktop
install_file $PRODUCTDIR/MainIcon.png /usr/share/pixmaps/sarma.player.png

# the app is started from its dir (Path= in the desktop file)
add_bin_cdexec_command sarma.player $PRODUCTDIR/$PRODUCT

subst "s|^Exec=.*|Exec=sarma.player|" $BUILDROOT/usr/share/applications/sarma.player.desktop
subst "/^Path=/d" $BUILDROOT/usr/share/applications/sarma.player.desktop
subst "s|^Icon=.*|Icon=sarma.player|" $BUILDROOT/usr/share/applications/sarma.player.desktop
chmod 0644 $BUILDROOT/usr/share/applications/sarma.player.desktop

# libvlc and libGL are loaded via dlopen
add_unirequires libvlc.so.5 libGL.so.1
