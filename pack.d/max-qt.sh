#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

mkdir -p opt/$PRODUCT/

# TODO: Add /qn for silent install ?
cat <<EOF >opt/$PRODUCT/run.sh
#!/bin/sh
INSTALLER="/opt/$PRODUCT/MAX.msi"

RUNFILE="\$HOME/.wine/drive_c/Program Files/MAX/max.exe"
if [ ! -f "\$RUNFILE" ] ; then
    WINEDLLOVERRIDES="winemenubuilder.exe=d" exec wine msiexec /i "\$INSTALLER"
fi
WINEDLLOVERRIDES="winemenubuilder.exe=d" exec wine "\$RUNFILE" "\$@"
EOF
chmod 755 opt/$PRODUCT/run.sh

cp $TAR opt/$PRODUCT/MAX.msi
erc pack $PKGNAME opt

return_tar $PKGNAME
