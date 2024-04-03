#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=Telegram
PRODUCTCUR=telegram-desktop
PKGNAME=$(basename $0 .sh)
PRODUCTDIR=/opt/Telegram

. $(dirname $0)/common.sh

# /usr/bin/Telegram
add_conflicts telegram-desktop
add_conflicts telegram-desktop-binary

for i in Telegram Telegram-beta ; do
    [ "$i"  = "$PKGNAME" ] && continue
    add_conflicts $i
done

add_bin_link_command
add_bin_link_command $PRODUCTCUR $PRODUCT

echo "$PRODUCTDIR/$PRODUCT" | create_file /usr/share/TelegramDesktop/externalupdater.d/telegram-desktop.conf

# TODO: tg.protocol
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=telegram-desktop-bin

add_libs_requires
