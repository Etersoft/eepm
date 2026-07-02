#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

APP_DIR="$TAR"
[ -d "$APP_DIR" ] || fatal "Can't find app directory"

CEF_DIR="$APP_DIR/cef"
[ -d "$CEF_DIR" ] || fatal "Can't find cef directory in the flatpak bundle"
[ -x "$CEF_DIR/GeForceNOW" ] || fatal "Can't find GeForceNOW binary in $CEF_DIR"

DESKTOP_FILE="$APP_DIR/share/applications/com.nvidia.geforcenow.desktop"

VERSION=$(sed -n 's/.*"productVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$APP_DIR/nvc/NvTelemetry.json" 2>/dev/null | head -n1)
[ -n "$VERSION" ] || fatal "Can't get version from NvTelemetry.json"

mkdir -p opt/$PRODUCT usr/bin usr/share/applications usr/share/icons

cp -a "$APP_DIR/"* opt/$PRODUCT/

cat <<EOF >usr/bin/$PRODUCT
#!/bin/sh
cd /opt/$PRODUCT/cef || exit 1
exec ./GeForceNOW "\$@"
EOF
chmod 755 usr/bin/$PRODUCT

cp "$DESKTOP_FILE" usr/share/applications/$PRODUCT.desktop || fatal "Can't copy desktop file"
subst "s|^Exec=.*|Exec=$PRODUCT %U|" usr/share/applications/$PRODUCT.desktop

cp -a "$APP_DIR/share/icons/"* usr/share/icons/ 2>/dev/null

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME opt usr

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Games
license: Proprietary
url: https://www.nvidia.com/en-us/geforce-now/
summary: NVIDIA GeForce NOW cloud gaming
description: NVIDIA GeForce NOW transforms your device into a high-end gaming rig.
EOF

return_tar $PKGNAME
