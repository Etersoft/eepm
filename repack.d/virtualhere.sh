#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=virtualhere
BINFILE=vhusbd

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Networking/Remote access|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://virtualhere.com/usb_server_software|" $SPEC
subst "s|^Summary:.*|Summary: Generic VirtualHere USB Server|" $SPEC

mkdir -p $BUILDROOT/etc/systemd/system/
cat << EOF > $BUILDROOT/etc/systemd/system/$PRODUCT.service
[Unit]
Description=VirtualHere Server
After=network.target
[Service]
Type=forking
ExecStart=$PRODUCTDIR/$BINFILE -b -c /etc/virtualhere/config.ini
[Install]
WantedBy=multi-user.target
EOF

mkdir -p $BUILDROOT/etc/$PRODUCT/
pack_dir /etc/$PRODUCT

pack_file /etc/systemd/system/$PRODUCT.service
