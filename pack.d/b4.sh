#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/bin
mkdir -p var/log/b4

erc --here $TAR || fatal

cp b4 usr/bin

chmod 755 usr/bin/b4

cat <<'EOF' | create_file /usr/lib/systemd/system/b4.service
[Unit]
Description=B4 DPI Bypass Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/b4
Restart=on-failure
RestartSec=5
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
EOF

erc pack $PKGNAME.tar usr var

return_tar $PKGNAME.tar
