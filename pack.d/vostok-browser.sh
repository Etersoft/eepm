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

VERSION="$(grep -E '^Version=' ru.xsoyuz.vostok/lib/vostok-browser/application.ini | cut -d= -f2)"

mkdir -p opt usr/bin usr/share/applications usr/share/icons

# the self-contained Firefox tree goes to /opt/vostok-browser
mv ru.xsoyuz.vostok/lib/vostok-browser opt/$PRODUCT

# bundle the Russian language pack as a system-wide extension
mkdir -p opt/$PRODUCT/distribution/extensions
cp ru.xsoyuz.vostok.Locale/langpack-ru@vostok-browser.xsoyuz.ru.xpi \
    opt/$PRODUCT/distribution/extensions/

# native launcher (the flatpak one pointed at /app)
cat <<EOF >usr/bin/$PRODUCT
#!/bin/sh
exec /opt/$PRODUCT/vostok-browser --name ru.xsoyuz.vostok "\$@"
EOF
chmod 755 usr/bin/$PRODUCT

# desktop entry and icons from the bundle
cp ru.xsoyuz.vostok/share/applications/ru.xsoyuz.vostok.desktop usr/share/applications/
cp -a ru.xsoyuz.vostok/share/icons/hicolor usr/share/icons/

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
