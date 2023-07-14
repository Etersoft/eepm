#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=discord
PRODUCTCUR=Discord
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common-chromium-browser.sh

move_to_opt

fix_chrome_sandbox

add_electron_deps

rm usr/bin/$PRODUCT
add_bin_link_command $PRODUCTCUR $PRODUCTDIR/$PRODUCTCUR
add_bin_link_command $PRODUCT $PRODUCTCUR

rm usr/share/applications/discord.desktop
install_file $PRODUCTDIR/discord.desktop /usr/share/applications/discord.desktop
rm usr/share/pixmaps/discord.png
install_file $PRODUCTDIR/discord.png /usr/share/pixmaps/discord.png

fix_desktop_file /usr/share/discord/Discord $PRODUCT
