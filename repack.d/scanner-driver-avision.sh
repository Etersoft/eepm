#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

cat <<EOF | create_file /etc/sane.d/dll.d/avision
# dll.conf snippet for Avision
#
avision_adv
EOF

# Install linked with libusb-1.0.so.0
# FIXME: version
install_file /opt/apps/scanner-driver-avision/sane/libsane-avision_adv.so.1.0.22_1.0 /usr/lib64/sane/libsane-avision_adv.so
install_file /opt/apps/scanner-driver-avision/sane/libsane-avision_adv.so.1.0.22_1.0 /usr/lib64/sane/libsane-avision_adv.so.1

add_libs_requires
