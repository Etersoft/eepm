#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

mkdir -p opt/$PRODUCT/

cat <<EOF >opt/$PRODUCT/run.sh
#!/bin/sh
INSTALLER="/opt/$PRODUCT/Yandex_Messenger_Setup.exe"

RUNFILE="\$HOME/.wine/drive_c/users/\$USER/AppData/Local/Programs/YandexMessenger/YandexMessenger.exe"
if [ ! -f "\$RUNFILE" ] ; then
    WINEDLLOVERRIDES="winemenubuilder.exe=d" exec wine "\$INSTALLER"
fi
WINEDLLOVERRIDES="winemenubuilder.exe=d" exec wine "\$RUNFILE" "\$@"
EOF
chmod 755 opt/$PRODUCT/run.sh

cp $TAR opt/$PRODUCT/Yandex_Messenger_Setup.exe
erc pack $PKGNAME opt

return_tar $PKGNAME
