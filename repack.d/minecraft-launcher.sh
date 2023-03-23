#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=minecraft-launcher

. $(dirname $0)/common.sh

add_requires java-openjdk at-spi2-atk file GConf glib2 grep libatk libat-spi2-core libalsa libcairo libcups libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst sed which xdg-utils xprop libsecret
