#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# The vendor's 40-scanner-permissions.rules sets MODE:="0666" on EVERY USB device,
# making all USB devices world-writable. Drop it (it ships under both /etc and /lib
# depending on deb/rpm source) and replace it with a rule scoped to Kyocera devices
# that grants access to the active local user (uaccess) and the scanner group.
remove_file /etc/udev/rules.d/40-scanner-permissions.rules
remove_file /lib/udev/rules.d/40-scanner-permissions.rules
cat <<EOF | create_file /lib/udev/rules.d/40-scanner-permissions.rules
# Kyocera SANE scanner USB permissions
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="0482", GROUP="scanner", MODE="0664", TAG+="uaccess", ENV{libsane_matched}="yes"
EOF

cat <<EOF | create_file /etc/sane.d/dll.d/kyocera
# dll.conf snippet for kyocera
#

kyocera
kyocera_gdi_a3
kyocera_wc3
kyocera_wc3_usb
EOF

# fix vendor's broken mind (from post install script)
for i in libkmip.so.1.0.* libkmscnapi.so libkmencapi.so libkmadrwapi.so libkmcmnapi2.so ; do
    to=$(echo usr/lib64/$i)
    nn=${i/.so*/.so.1}
    ln -s $(basename $to) usr/lib64/$nn
    pack_file /usr/lib64/$nn
done

# fix vendor's broken mind (from post install script)
for i in libsane-kyocera.so.1.0.* libsane-kyocera_gdi_a3.so.1.0.* libsane-kyocera_wc3.so.1.0.* libsane-kyocera_wc3_usb.so.1.0.* ; do
    to=$(echo usr/lib64/sane/$i)
    nn=${i/.so*/.so.1}
    ln -s $(basename $to) usr/lib64/sane/$nn
    pack_file /usr/lib64/sane/$nn
done

remove_dir /usr/local

#if [ ! -e /usr/lib64/libssl.so.1.1 ]; then 
#      ln -s /usr/local/kyocera/scanner/libssl.so.1.1 /usr/lib64/libssl.so.1.1
#fi

#if [ ! -e /usr/lib64/libcrypto.so.1.1 ]; then 
#      ln -s /usr/local/kyocera/scanner/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
#fi

