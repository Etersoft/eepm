#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

erc -C opt/eepm-wine/$PRODUCT unpack $TAR || fatal

cat <<EOF >opt/eepm-wine/$PRODUCT/run.sh
#!/bin/sh
RUNFILE="/opt/eepm-wine/faststone-image-viewer/FSViewer.exe"
exec wine "\$RUNFILE" "\$@"
EOF
chmod 755 opt/eepm-wine/$PRODUCT/run.sh

erc pack $PKGNAME opt/eepm-wine

return_tar $PKGNAME
