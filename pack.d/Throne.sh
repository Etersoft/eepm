#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oP '\d+(\.\d+)+' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/bin
mkdir -p usr/share/pixmaps
erc -C opt/$PRODUCT $TAR || fatal

mv -v opt/$PRODUCT/$PRODUCT.png usr/share/pixmaps/

cat <<EOF | create_file /usr/share/applications/Throne.desktop
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
    cp -a \$nekoray_datadir \$datadir
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

erc pack $PKGNAME.tar usr opt

return_tar $PKGNAME.tar
