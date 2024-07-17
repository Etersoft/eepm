#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

mkdir -p opt/eepm-wine/$PRODUCT/

cat <<EOF >opt/eepm-wine/$PRODUCT/run.sh
#!/bin/sh
RUNFILE="/opt/eepm-wine/winbox/winbox64.exe"
exec wine "\$RUNFILE" "\$@"
EOF
chmod 755 opt/eepm-wine/$PRODUCT/run.sh

cp $TAR opt/eepm-wine/$PRODUCT/
erc pack $PKGNAME opt/eepm-wine

return_tar $PKGNAME
