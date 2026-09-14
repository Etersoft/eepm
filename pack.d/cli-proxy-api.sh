#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

# replace the last '-' with '~' so __set_name_version_by_tarball parses the version correctly
VERSION="$(echo "$VERSION" | sed 's/-\([^-]*\)$/~\1/')"

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/bin
mkdir -p usr/share/doc/$PRODUCT
erc --here unpack $TAR || fatal

mv -v $PRODUCT usr/bin/$PRODUCT

mv -v config.example.yaml usr/share/doc/$PRODUCT/config.example.yaml

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
