#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

# the vendor ships versionless binaries; use the Last-Modified date
# (preserved as the file mtime by eget) as the package version
[ "$VERSION" = "*" ] && VERSION=""
[ -n "$VERSION" ] || VERSION="$(date -u -r "$TAR" +%Y.%m.%d 2>/dev/null)"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION
PRODUCTDIR=/opt/$PRODUCT

CONSOLEURL="https://www.distkontrol.com/upload/clients/linux-console"

mkdir -p usr/bin etc/$PRODUCT

case "$(basename "$TAR")" in
    dkclt64)
        # GUI client (it can work as a console client too, but needs a display)
        install -m0755 -D "$TAR" .$PRODUCTDIR/dkclt64 || fatal
        ln -s $PRODUCTDIR/dkclt64 usr/bin/dkclt64
        # console client to run as a service
        eget -O dkclientx86_64 "$CONSOLEURL/dkclientx86_64" || fatal
        install -m0755 -D dkclientx86_64 .$PRODUCTDIR/dkclient || fatal
        ;;
    dkclient*)
        install -m0755 -D "$TAR" .$PRODUCTDIR/dkclient || fatal
        ;;
    *)
        fatal "Unknown file $TAR"
        ;;
esac

ln -s $PRODUCTDIR/dkclient usr/bin/dkclient

# uses the kernel vhci_hcd driver (USB/IP) to attach remote devices
echo "vhci-hcd" | create_file /usr/lib/modules-load.d/$PRODUCT.conf

cat <<EOF | create_file /usr/lib/systemd/system/$PRODUCT.service
[Unit]
Description=DistKontrolUSB Client
After=network.target

[Service]
Type=forking
ExecStartPre=-/sbin/modprobe vhci-hcd
ExecStart=$PRODUCTDIR/dkclient -n -c /etc/$PRODUCT/client.ini

[Install]
WantedBy=multi-user.target
EOF

erc pack $PKGNAME.tar opt usr etc || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Remote access
license: Proprietary
url: https://www.distkontrol.com/
summary: DistKontrolUSB Client - use USB devices over a network
description: DistKontrolUSB Client allows to use USB devices connected to DistKontrolUSB hub over a network.
EOF

return_tar $PKGNAME.tar
