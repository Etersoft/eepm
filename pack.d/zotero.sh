#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

BASENAME=$(basename $1 .tar.xz)
VERSION=$(echo "$BASENAME" | sed -E 's/^Zotero-([0-9.]+)_.*/\1/')
ARCH=$(echo "$BASENAME" | sed -E 's/^.*_linux-//')
mkdir -p opt
mkdir -p usr/share/applications/

erc unpack $TAR || fatal
mv -v Zotero_linux-$ARCH opt/$PRODUCT

for size in 32 64 128; do
  mkdir -p "usr/share/icons/hicolor/${size}x${size}/apps"
  mv -v "opt/$PRODUCT/icons/icon${size}.png" \
        "usr/share/icons/hicolor/${size}x${size}/apps/zotero.png"
done

mkdir -p "usr/share/icons/hicolor/symbolic/apps"
mv -v "opt/$PRODUCT/icons/symbolic.svg" \
      "usr/share/icons/hicolor/symbolic/apps/zotero-symbolic.svg"

# HACK: broke autoupdate
subst 's|^URL=https://www\.zotero\.org/.*|URL=http://localhost/update.xml|' opt/$PRODUCT/app/application.ini

cat <<EOF | create_file /usr/share/applications/zotero.desktop
[Desktop Entry]
Name=Zotero
GenericName=Reference management tool
Comment=Your personal research assistant
Exec=zotero -url %U
Icon=zotero
Type=Application
Terminal=false
Categories=Office;
MimeType=text/plain;x-scheme-handler/zotero;application/x-research-info-systems;text/x-research-info-systems;text/ris;application/x-endnote-refer;application/x-inst-for-Scientific-info;application/mods+xml;application/rdf+xml;application/x-bibtex;text/x-bibtex;application/marc;application/vnd.citationstyles.style+xml
X-GNOME-SingleWindow=true
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
