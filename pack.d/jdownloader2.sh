#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION=2
PKGNAME=$PRODUCT-$VERSION

mkdir -p opt/$PRODUCT
mkdir -p usr/bin

cp $TAR opt/$PRODUCT/JDownloader.jar || fatal

install_file "https://github.com/pkg-src/jdownloader2.snap/blob/master/snap/gui/JDownloader.png?raw=true" "usr/share/pixmaps/$PRODUCT.png"

cat <<EOF >"usr/bin/$PRODUCT"
#!/bin/sh
set -e

JD_HOME="\${XDG_DATA_HOME:-\$HOME/.local/share}/$PRODUCT"
mkdir -p "\$JD_HOME"
[ -f "\$JD_HOME/JDownloader.jar" ] || cp /opt/$PRODUCT/JDownloader.jar "\$JD_HOME/JDownloader.jar"
cd "\$JD_HOME"
exec /usr/bin/java -jar JDownloader.jar "\$@"
EOF
chmod 755 "usr/bin/$PRODUCT" || fatal

cat <<EOF | create_file "usr/share/applications/$PRODUCT.desktop"
[Desktop Entry]
Type=Application
Name=JDownloader 2
Comment=Download management tool
Exec=$PRODUCT
Icon=$PRODUCT
Categories=Network;FileTransfer;
Terminal=false
EOF

erc pack "$PKGNAME.tar" opt usr || fatal

return_tar "$PKGNAME.tar"
