#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

epm assure ostree || fatal

# Flatpak descriptors are INI files; KDE uses spaces around '='.
ref_value()
{
    sed -n "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*//; T; s/[[:space:]]*$//; p" "$TAR"
}

BRANCH="$(ref_value Branch)"
REPO_URL="$(ref_value Url)"
REPO="$(pwd)/.ostree-repo"
a='' ostree init --repo="$REPO" --mode=archive || fatal
a='' ostree remote add --repo="$REPO" --no-gpg-verify kwi "$REPO_URL" || fatal
REF="app/org.kde.kwi/$(epm print info -a)/$BRANCH"
a='' ostree pull --repo="$REPO" kwi "$REF" || fatal "Can't pull Kwi"
a='' ostree checkout --repo="$REPO" --user-mode "kwi:$REF" app_checkout || fatal

mkdir -p "opt/$PRODUCT/bin" "opt/$PRODUCT/lib" usr/bin usr/share || fatal
cp -a app_checkout/files/bin/kwi "opt/$PRODUCT/bin/" || fatal
for lib in libkwi-terminal libghostty-vt libKirigamiActionCollection ; do
    cp -a app_checkout/files/lib/$lib.so* "opt/$PRODUCT/lib/" || fatal
done
# Union style libraries (libUnion, libUnionQuickImpl, libUnionQuickPrivate, ...)
cp -a app_checkout/files/lib/libUnion*.so* "opt/$PRODUCT/lib/" || fatal
for dir in qml/org/kde/kwi/terminal qml/org/kde/union qml/org/kde/kirigami/actioncollection \
           qml/org/kde/kirigami/styles/org.kde.union plugins/union ; do
    mkdir -p "opt/$PRODUCT/lib/$(dirname "$dir")" || fatal
    cp -a "app_checkout/files/lib/$dir" "opt/$PRODUCT/lib/$dir" || fatal
done
mkdir -p "opt/$PRODUCT/lib/plugins/styles" "opt/$PRODUCT/lib/plugins/kf6/kirigami/platform" || fatal
cp -a app_checkout/files/lib/plugins/styles/UnionWidgetsStyle.so "opt/$PRODUCT/lib/plugins/styles/" || fatal
cp -a app_checkout/files/lib/plugins/kf6/kirigami/platform/org.kde.union.so "opt/$PRODUCT/lib/plugins/kf6/kirigami/platform/" || fatal
for dir in kwi union kstyle config.kcfg knotifications6 licenses applications icons metainfo ; do
    cp -a "app_checkout/files/share/$dir" usr/share/ || fatal
done

cat > "usr/bin/$PRODUCT" <<EOF
#!/bin/sh
export LD_LIBRARY_PATH="/opt/$PRODUCT/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
export QML_IMPORT_PATH="/opt/$PRODUCT/lib/qml\${QML_IMPORT_PATH:+:\$QML_IMPORT_PATH}"
export QT_PLUGIN_PATH="/opt/$PRODUCT/lib/plugins\${QT_PLUGIN_PATH:+:\$QT_PLUGIN_PATH}"
exec /opt/$PRODUCT/bin/kwi "\$@"
EOF
chmod 755 "usr/bin/$PRODUCT" || fatal

DESKTOP=usr/share/applications/org.kde.kwi.desktop
subst 's|/app/bin/kwi|kwi|g' "$DESKTOP"
find usr/share/icons -name icon-theme.cache -type f -delete || fatal

a='' ostree show --repo="$REPO" "kwi:$REF" > "$REPO/commit.info" || fatal
VERSION=$(sed -n 's/^Date: *//p' "$REPO/commit.info" | head -n1 | cut -d' ' -f1,2 | tr -cd '0-9')
[ -n "$VERSION" ] || fatal "Can't determine Kwi nightly version"
rm -rf "$REPO" app_checkout || fatal
PKGNAME="$PRODUCT-$VERSION.tar"
erc pack "$PKGNAME" opt usr || fatal
cat > "$PKGNAME.eepm.yaml" <<EOF
name: $PRODUCT
version: $VERSION
group: Terminals
license: GPL-2.0-or-later
url: https://invent.kde.org/utilities/kwi
summary: Kwi nightly terminal
description: Kwi terminal for KDE Plasma and other desktops.
EOF
return_tar "$PKGNAME"
