#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION.tar

mkdir -p opt/$PRODUCT/

# AeroAdmin is a single portable Windows .exe, just run it under Wine
cp $TAR opt/$PRODUCT/AeroAdmin.exe

cat <<EOF >opt/$PRODUCT/run.sh
#!/bin/sh
WINEDLLOVERRIDES="winemenubuilder.exe=d" exec wine "/opt/$PRODUCT/AeroAdmin.exe" "\$@"
EOF
chmod 755 opt/$PRODUCT/run.sh

# launcher command
mkdir -p usr/bin
ln -s /opt/$PRODUCT/run.sh usr/bin/$PRODUCT

# menu integration
mkdir -p usr/share/applications
cat <<EOF >usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Type=Application
Name=AeroAdmin
Comment=Remote desktop access and control
Exec=$PRODUCT
Terminal=false
Categories=Network;RemoteAccess;
EOF

erc pack $PKGNAME opt usr

return_tar $PKGNAME
