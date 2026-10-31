#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# TAR is vostok.tar.gz holding two flatpak bundles (the app and its Locale)
erc --here unpack "$TAR"

# unpack both bundles via ostree (erc handles flatpak without flatpak installed):
#   ru.xsoyuz.vostok/         - the app tree (lib/vostok-browser is the browser)
#   ru.xsoyuz.vostok.Locale/  - the Russian language pack (xpi)
erc ru.xsoyuz.vostok.flatpak
erc ru.xsoyuz.vostok.Locale.flatpak

APPDIR=ru.xsoyuz.vostok
APP_TREE="$APPDIR/lib/vostok"

[ -r "$APP_TREE/application.ini" ] || fatal "Can't find Vostok application.ini"
VERSION="$(grep -E '^Version=' "$APP_TREE/application.ini" | cut -d= -f2)"
[ -n "$VERSION" ] || fatal "Can't detect Vostok version"

mkdir -p opt usr/bin usr/share/applications usr/share/icons

# the self-contained Firefox tree goes to /opt/vostok-browser
mv "$APP_TREE" opt/$PRODUCT || fatal

# bundle the Russian language pack as a system-wide extension
mkdir -p opt/$PRODUCT/distribution/extensions
LANGPACK=langpack-ru@vostok-browser.xsoyuz.ru.xpi
rm -f "opt/$PRODUCT/distribution/extensions/$LANGPACK" || fatal
cp "ru.xsoyuz.vostok.Locale/$LANGPACK" \
    "opt/$PRODUCT/distribution/extensions/$LANGPACK" || fatal

# native launcher (the flatpak one pointed at /app)
cat <<EOF >usr/bin/$PRODUCT
#!/bin/sh
exec /opt/$PRODUCT/vostok --name ru.xsoyuz.vostok "\$@"
EOF
chmod 755 usr/bin/$PRODUCT

# desktop entry and icons from the bundle
cp "$APPDIR/share/applications/ru.xsoyuz.vostok.desktop" usr/share/applications/
subst 's|^Exec=vostok|Exec=vostok-browser|' usr/share/applications/ru.xsoyuz.vostok.desktop
cp -a "$APPDIR/share/icons/hicolor" usr/share/icons/

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME opt usr

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Networking/WWW
license: MPL-2.0
url: https://c01-03.ru
summary: C01-03 Vostok web browser
description: C01-03 Vostok, a Firefox-based web browser.
EOF

return_tar $PKGNAME
