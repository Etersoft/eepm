#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vinteo.desktop
PRODUCTDIR=/opt/VinteoDesktop

. $(dirname $0)/common-chromium-browser.sh

add_bin_link_command

fix_desktop_file

fix_chrome_sandbox

add_electron_deps

add_findreq_skiplist "/opt/VinteoDesktop/resources/app.asar.unpacked/node_modules/@serialport/bindings-cpp/prebuilds/*/*.node"

case "$(epm print info -e)" in
    ALTLinux/p9)
        # bindings.node: /lib64/libc.so.6: version `GLIBC_2.28' not found
        echo "TODO: build node-serialport package if needed"
        remove_dir $PRODUCTDIR/resources/app.asar.unpacked/node_modules/@serialport/bindings-cpp/prebuilds/
        remove_dir $PRODUCTDIR/resources/app.asar.unpacked/node_modules/@serialport/bindings-cpp/build/
        remove_dir $PRODUCTDIR/resources/app.asar.unpacked/node_modules/@serialport/bindings-cpp/bin/
        ;;
esac

