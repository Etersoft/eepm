#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"

. $(dirname $0)/common.sh

VERSION=$(echo "$URL" | grep -oP 'OneScript-\K[0-9]+\.[0-9]+\.[0-9]+')
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack $TAR || fatal

chmod 755 opt/$PRODUCT/bin/oscript

# fix opm script to use absolute path
cat <<'EOF' >opt/$PRODUCT/bin/opm
#!/bin/sh
LIB="/opt/onescript-engine/lib"
OPM="$LIB/opm/src/cmd/opm.os"
exec /opt/onescript-engine/bin/oscript "$OPM" "$@"
EOF
chmod 755 opt/$PRODUCT/bin/opm

mkdir -p usr/bin
ln -s /opt/$PRODUCT/bin/oscript usr/bin/oscript
ln -s /opt/$PRODUCT/bin/opm usr/bin/opm

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Other
license: MPL-2.0
url: https://oscript.io/
summary: OneScript scripting language based on 1C syntax
description: OneScript is a scripting language based on 1C:Enterprise syntax for automation and scripting tasks.
EOF

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
