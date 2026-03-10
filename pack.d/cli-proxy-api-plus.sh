#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/bin
mkdir -p usr/share/doc/$PRODUCT
erc --here unpack $TAR || fatal

BASENAME=$(basename $1 .tar.gz)
ARCH=$(echo "$BASENAME" | sed -E 's/^.*_linux_//')

mv -v CLIProxyAPIPlus_${VERSION}_linux_${ARCH}/$PRODUCT usr/bin/$PRODUCT

mv -v CLIProxyAPIPlus_${VERSION}_linux_${ARCH}/config.example.yaml usr/share/doc/$PRODUCT/config.example.yaml

chmod 755 usr/bin/$PRODUCT

cat <<EOF | create_file /usr/lib/systemd/user/$PRODUCT.service
[Unit]
Description=CLIProxyAPI Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/$PRODUCT --config %h/.cli-proxy-api/config.yaml
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

erc pack $PKGNAME.tar usr

return_tar $PKGNAME.tar
