#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

mkdir -p opt/eepm-wine/$PRODUCT/

cat <<EOF >opt/eepm-wine/$PRODUCT/run.sh
#!/bin/sh
INSTALLER="/opt/eepm-wine/$PRODUCT/$(basename $TAR)"
# TODO: duplicate menu entries, drop original entries
# FIXME: use could select other path
RUNFILE='C:\Program Files (x86)\CommFort\CommFort.exe'
URUNFILE="\$(winepath -u "\$RUNFILE")"
if [ ! -f "\$URUNFILE" ] ; then
    exec wine "\$INSTALLER"
fi
exec wine "\$RUNFILE" "\$@"
EOF
chmod 755 opt/eepm-wine/$PRODUCT/run.sh

cp $TAR opt/eepm-wine/$PRODUCT/
erc pack $PKGNAME opt/eepm-wine

return_tar $PKGNAME
