#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

erc unpack $TAR || fatal
cd *

# drop dirname with spaces
mv -v "opt/Яндекс Музыка" opt/yandex-music || fatal

# disable autoupdate
rm -v opt/yandex-music/resources/app-update.yml


cat <<EOF > create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
# workaround for https://github.com/electron/electron/issues/46538
/opt/yandex-music/$PRODUCT --gtk-version=3
EOF

subst "s|^Exec=.*|Exec=$PRODUCT %U|" usr/share/applications/yandexmusic.desktop

erc pack $PKGNAME opt usr

return_tar $PKGNAME
