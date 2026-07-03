#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# TAR is the official Orion Flatpak bundle (com.kagi.OrionGtk).
# erc unpacks it via ostree (no flatpak runtime needed) into a dir named after
# the bundle basename, e.g. oriongtk.0.3.0(.arm)
erc "$TAR"

APPDIR="$(find . -maxdepth 1 -mindepth 1 -type d -name 'oriongtk*' | head -1)"
[ -d "$APPDIR" ] || fatal "Can't find the extracted Orion tree"

VERSION="$(grep -oE 'release version="[^"]+"' "$APPDIR"/share/metainfo/*.metainfo.xml 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)".*/\1/')"
[ -n "$VERSION" ] || VERSION="0.3.0"

mkdir -p opt usr/bin usr/share/applications usr/share/icons/hicolor

# The whole /app tree (binary, bundled WebKitGTK/JSC, helper processes, data)
# becomes /opt/$PRODUCT. (opt/$PRODUCT must not exist yet, so mv renames the
# extracted dir instead of nesting it.) The binary has /app compiled in and looks
# up its bundled libs under /app/lib64; the launcher reconstructs that environment.
mv "$APPDIR" opt/$PRODUCT

# native launcher: put the bundled libs on the search path and point WebKitGTK at
# its helper processes and injected bundle under /opt/$PRODUCT.
cat <<EOF >usr/bin/$PRODUCT
#!/bin/sh
# Orion is a repackaged Flatpak app: its binary and bundled WebKitGTK expect the
# /app prefix. Reconstruct that environment so it runs natively.
ORION=/opt/$PRODUCT
export LD_LIBRARY_PATH="\$ORION/lib64:\$ORION/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
export WEBKIT_EXEC_PATH="\$ORION/libexec/webkitgtk-6.0"
export WEBKIT_INJECTED_BUNDLE_PATH="\$ORION/lib64/webkitgtk-6.0/injected-bundle"
export XDG_DATA_DIRS="\$ORION/share:\${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
exec "\$ORION/bin/oriongtk" "\$@"
EOF
chmod 755 usr/bin/$PRODUCT

# desktop entry: keep the upstream one but run via the native launcher
if [ -f "opt/$PRODUCT/share/applications/com.kagi.OrionGtk.desktop" ] ; then
    cp "opt/$PRODUCT/share/applications/com.kagi.OrionGtk.desktop" usr/share/applications/
    subst "s|^Exec=.*|Exec=$PRODUCT|" usr/share/applications/com.kagi.OrionGtk.desktop
fi

# icons (standard hicolor layout)
cp -a opt/$PRODUCT/share/icons/hicolor/. usr/share/icons/hicolor/ 2>/dev/null ||:

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME opt usr

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Networking/WWW
license: Commercial - Third party EULA
url: https://orionbrowser.com/platforms/linux
summary: Orion Browser by Kagi (Linux beta, WebKitGTK/GTK4)
description: Orion is a privacy-focused web browser by Kagi, built on WebKitGTK and GTK4/libadwaita. This package repacks the official Linux Flatpak bundle to run natively. Its bundled WebKit links libicu*.so.77 (built against the GNOME 49 runtime); install 'epm play libicu77' to provide it.
EOF

return_tar $PKGNAME
