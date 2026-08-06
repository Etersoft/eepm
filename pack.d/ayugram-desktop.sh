#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

APP_ID=com.ayugram.desktop
APP_BIN=ayugram-desktop

# TAR is the community Flatpak bundle. Official AyuGram Linux deb/AppImage
# builds are not published yet, and the Arch package is tied to rolling libs.
epm assure ostree || fatal

erc "$TAR" || fatal

APPDIR="$(find . -maxdepth 3 -type f -path "*/bin/$APP_BIN" | head -n1 | sed "s|/bin/$APP_BIN$||")"
[ -n "$APPDIR" ] && [ -d "$APPDIR" ] || fatal "Can't find $APP_BIN in the extracted Flatpak bundle"

VERSION="$(grep -oE 'release version="[^"]+"' "$APPDIR"/share/metainfo/$APP_ID.metainfo.xml 2>/dev/null | head -n1 | sed 's/.*"\([^"]*\)".*/\1/' | sed 's|~.*||')"
[ -n "$VERSION" ] || fatal "Can't extract AyuGram version from the Flatpak bundle"

mkdir -p opt usr/bin usr/share/applications usr/share/icons/hicolor usr/share/metainfo

mv "$APPDIR" opt/$PRODUCT || fatal

cat <<EOF >usr/bin/$PRODUCT
#!/bin/sh
AYUGRAM_DIR=/opt/$PRODUCT
export XDG_DATA_DIRS="\$AYUGRAM_DIR/share:\${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
exec "\$AYUGRAM_DIR/bin/$APP_BIN" "\$@"
EOF
chmod 755 usr/bin/$PRODUCT || fatal
ln -snf $PRODUCT usr/bin/ayugram || fatal

if [ -f "opt/$PRODUCT/share/applications/$APP_ID.desktop" ] ; then
    # Use a single .desktop suffix outside Flatpak.
    mv "opt/$PRODUCT/share/applications/$APP_ID.desktop" "usr/share/applications/$APP_ID" || fatal
    subst "s|^Exec=.*|Exec=$PRODUCT -- %u|" usr/share/applications/$APP_ID
    subst "s|^TryExec=.*|TryExec=$PRODUCT|" usr/share/applications/$APP_ID
    subst "s|^DBusActivatable=.*|DBusActivatable=false|" usr/share/applications/$APP_ID
fi

if [ -f "opt/$PRODUCT/share/dbus-1/services/$APP_ID.service" ] ; then
    subst "s|^Exec=.*|Exec=/usr/bin/$PRODUCT|" opt/$PRODUCT/share/dbus-1/services/$APP_ID.service
fi

cp -a opt/$PRODUCT/share/icons/hicolor/. usr/share/icons/hicolor/ 2>/dev/null ||:
subst "s|>$APP_ID.desktop<|>$APP_ID<|" opt/$PRODUCT/share/metainfo/$APP_ID.metainfo.xml
cp opt/$PRODUCT/share/metainfo/$APP_ID.metainfo.xml usr/share/metainfo/ 2>/dev/null ||:

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME opt usr || fatal

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Networking/Instant messaging
license: GPLv3
url: https://github.com/AyuGram/AyuGramDesktop
summary: AyuGram Desktop
description: Desktop Telegram client with good customization and Ghost mode.
EOF

return_tar $PKGNAME
