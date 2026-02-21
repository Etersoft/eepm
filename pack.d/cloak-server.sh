#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

install -D $TAR usr/bin/ck-server || fatal

mkdir -p etc/cloak

cat <<EOF | create_file /usr/lib/systemd/system/cloak-server.service
[Unit]
Description=Cloak Server
After=network.target

[Service]
ExecStart=/usr/bin/ck-server -c /etc/cloak/ckserver.json
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

erc pack $PKGNAME.tar usr etc

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking
license: GPL-3.0
url: https://github.com/cbeuw/Cloak
summary: Cloak server - censorship circumvention tool
description: A pluggable transport that enhances traditional proxy tools to evade deep packet inspection.
EOF

return_tar $PKGNAME.tar
