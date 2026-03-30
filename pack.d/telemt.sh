#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

mkdir -p opt/$PRODUCT
erc --here unpack "$TAR" || fatal
cp $PRODUCT opt/$PRODUCT/$PRODUCT || fatal "Can't find $PRODUCT binary in archive"
chmod 755 opt/$PRODUCT/$PRODUCT

[ -n "$VERSION" ] || VERSION="1.0"

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/bin
ln -s /opt/$PRODUCT/$PRODUCT usr/bin/$PRODUCT

mkdir -p etc
cat <<EOF >etc/$PRODUCT.toml
# Telemt MTProxy configuration
# See https://github.com/telemt/telemt for details

[general]
seed = ""

[server]
port = 8443

[[upstreams]]
dc = 1
host = "149.154.175.50"
port = 443

[[upstreams]]
dc = 2
host = "149.154.167.51"
port = 443

[[upstreams]]
dc = 3
host = "149.154.175.100"
port = 443

[[users]]
name = "user1"
secret = ""
EOF

mkdir -p usr/lib/systemd/system
cat <<EOF >usr/lib/systemd/system/$PRODUCT.service
[Unit]
Description=Telemt MTProxy Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/opt/$PRODUCT/$PRODUCT /etc/$PRODUCT.toml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Proxy
license: MIT
url: https://github.com/telemt/telemt
summary: Telemt MTProxy - high-performance Telegram proxy server
description: High-performance MTProxy server for Telegram written in Rust + Tokio. Supports classic, secure and fake-TLS modes with connection pooling, replay protection and traffic masking.
EOF

erc pack $PKGNAME.tar opt usr etc || fatal

return_tar $PKGNAME.tar
