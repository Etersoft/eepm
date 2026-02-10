#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
URL="$4"

. $(dirname $0)/common.sh

erc unpack $TAR || fatal

mkdir -p opt
mkdir -p usr/bin
mkdir -p usr/share/pixmaps
mv -v $PRODUCT opt/$PRODUCT
mv -v opt/$PRODUCT/Throne.png usr/share/pixmaps/

VERSION=$(echo "$URL" | grep -oE '[0-9]+(\.[0-9]+)+' | head -n1)
[ -n "$VERSION" ] || fatal "Can't get package version"

cat <<EOF > usr/bin/throne
#!/bin/sh
# Correctly handle non-standard config directory
confdir=\${XDG_CONFIG_HOME:-\$HOME/.config}

datadir=\$confdir/Throne
appdir=/opt/Throne

# Prepare appdata
if [ ! -d \$datadir ]; then
  nekoray_datadir=\$confdir/nekoray

  if [ -d \$nekoray_datadir ]; then
    # Migrate appdata from nekoray
    cp -a \$nekoray_datadir $datadir
  else
    mkdir -p \$datadir
  fi
fi

# Remove broken (since 1.0.2-beta.1) links to geo assets
if [ -L \$datadir/geoip.db ] || [ -L \$datadir/geosite.db ]; then
  rm -f \$datadir/geo{ip,site}.db
fi

# Run application
\$appdir/Throne -- -appdata
EOF

chmod 755 usr/bin/throne

cat <<EOF | create_file /usr/share/applications/throne.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Throne
Comment=Cross-platform GUI proxy utility (Empowered by sing-box)
Exec=throne
Icon=Throne
Terminal=false
StartupNotify=false
StartupWMClass=Throne
Categories=Network;
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
