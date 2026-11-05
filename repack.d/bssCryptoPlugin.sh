#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt /usr/share/BSS/$PRODUCT
remove_dir /usr/share/BSS

# used only by the original maintainer scripts
remove_file $PRODUCTDIR/host_exit.sh

# loaded via dlopen by libmesprox.so (it has RUNPATH $ORIGIN)
move_file /usr/lib/libscbrng.so $PRODUCTDIR/libscbrng.so

add_bin_link_command $PRODUCT $PRODUCTDIR/bssPluginHost
fix_desktop_file /usr/share/BSS/$PRODUCT/bssPluginHost $PRODUCT

# the original installer copies the desktop file to ~/.config/autostart
mkdir -p $BUILDROOT/etc/xdg/autostart
cp $BUILDROOT/usr/share/applications/$PRODUCT.desktop $BUILDROOT/etc/xdg/autostart/$PRODUCT.desktop
pack_file /etc/xdg/autostart/$PRODUCT.desktop

# loaded via dlopen
add_unirequires libssl.so.1.1 libcrypto.so.1.1

# pcscd and CCID reader driver are needed for smart card tokens
add_requires /usr/sbin/pcscd
case "$(epm print info -p)" in
    deb)
        add_requires libccid
        ;;
    *)
        # provided by pcsc-lite-ccid in ALT and Fedora, ccid in ROSA
        add_requires ccid
        ;;
esac
