#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

mkdir -p opt/eepm-wine/$PRODUCT/

cat <<EOF >opt/eepm-wine/$PRODUCT/run.sh
#!/bin/sh
INSTALLER="/opt/eepm-wine/yandex-telemost/TelemostSetup.exe"
WINE_PROG_PATH=\$(wine cmd /c echo %appdata% | tr -d '\r')
NORMAL_PATH=\$(winepath -u "\$WINE_PROG_PATH\Yandex\YandexTelemost")
INSTALLED_VER=\$(ls "\$NORMAL_PATH")

RUNFILE="\$NORMAL_PATH/\$INSTALLED_VER/YandexTelemost.exe"
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
