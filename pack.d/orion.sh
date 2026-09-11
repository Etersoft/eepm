#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# TAR is the official Orion Flatpak bundle (com.kagi.OrionGtk).
# erc unpacks it via ostree (no flatpak runtime needed) into a dir named after
# the bundle basename, e.g. oriongtk.0.3.0(.arm)
erc "$TAR" || fatal

APPDIR="$(find . -maxdepth 1 -mindepth 1 -type d -name 'oriongtk*' | head -1)"
[ -d "$APPDIR" ] || fatal "Can't find the extracted Orion tree"

VERSION="$(grep -oE 'release version="[^"]+"' "$APPDIR"/share/metainfo/*.metainfo.xml 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)".*/\1/')"
[ -n "$VERSION" ] || VERSION="0.3.0"

mkdir -p opt usr/bin usr/share/applications usr/share/icons/hicolor

# The whole /app tree (binary, bundled WebKitGTK/JSC, helper processes, data)
# becomes /opt/$PRODUCT. (opt/$PRODUCT must not exist yet, so mv renames the
# extracted dir instead of nesting it.) The launcher finds its bundled libs;
# repack.d/orion.sh relocates WebKit's compiled-in helper process directory.
mv "$APPDIR" opt/$PRODUCT || fatal

# p11's GCC 13 runtime lacks GLIBCXX_3.4.34 / CXXABI_1.3.15. Bundle the
# GNOME 49 libstdc++ privately; it works with p11's glibc 2.38.
ARCH="$(epm print info -a)"
case "$ARCH" in
    x86_64) RUNTIME_LIBDIR=x86_64-linux-gnu ;;
    aarch64) RUNTIME_LIBDIR=aarch64-linux-gnu ;;
    *) fatal "Unsupported architecture for $PRODUCT" ;;
esac
REPO="$(mktemp -d)" || fatal
trap 'rm -rf "$REPO"' EXIT
trap 'exit 1' HUP INT TERM
eget -O "$REPO/flathub.flatpakrepo" https://dl.flathub.org/repo/flathub.flatpakrepo || fatal
prepare_flatpak_runtime "$REPO" "$REPO/flathub.flatpakrepo" "runtime/org.gnome.Platform/$ARCH/49"
COMMIT="$FLATPAK_RUNTIME_COMMIT"
LIBPATH="/files/lib/$RUNTIME_LIBDIR"
ostree pull --repo="$REPO" --subpath="$LIBPATH/libstdc++.so.6" flathub "$COMMIT" || fatal
LIBFILE="$(ostree ls --repo="$REPO" "$COMMIT" "$LIBPATH/libstdc++.so.6" | sed -n 's/.* -> \(libstdc++\.so\.6\.[0-9.]*\)$/\1/p')"
[ -n "$LIBFILE" ] || fatal "Can't resolve libstdc++.so.6 in GNOME 49"
ostree pull --repo="$REPO" --subpath="$LIBPATH/$LIBFILE" flathub "$COMMIT" || fatal
ostree cat --repo="$REPO" "$COMMIT" "$LIBPATH/$LIBFILE" > "opt/$PRODUCT/lib64/libstdc++.so.6" || fatal
chmod 755 "opt/$PRODUCT/lib64/libstdc++.so.6" || fatal

# Native launcher: use the private libraries and injected bundle.
cat <<EOF >usr/bin/$PRODUCT
#!/bin/sh
# Use Orion's private libraries, including the matching C++ runtime.
ORION=/opt/$PRODUCT
export LD_LIBRARY_PATH="\$ORION/lib64:\$ORION/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
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
erc pack $PKGNAME opt usr || fatal

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Networking/WWW
license: Commercial - Third party EULA
url: https://orionbrowser.com/platforms/linux
summary: Orion Browser by Kagi (Linux beta, WebKitGTK/GTK4)
description: Orion is a privacy-focused web browser by Kagi, built on WebKitGTK and GTK4/libadwaita. This package repacks the official Linux Flatpak bundle to run natively. Its bundled WebKit links libicu*.so.77 and libxml2.so.16 (built against the GNOME 49 runtime); epm play orion installs libicu77 and libxml2_16 when needed.
EOF

return_tar $PKGNAME
