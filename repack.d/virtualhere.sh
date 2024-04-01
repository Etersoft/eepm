#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=virtualhere
BINFILE=vhusbd

. $(dirname $0)/common.sh

cat << EOF | create_file /etc/systemd/system/$PRODUCT.service
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

add_libs_requires
