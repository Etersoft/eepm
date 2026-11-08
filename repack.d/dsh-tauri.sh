#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PKGNAME=deepseek-harness-desktop
subst "s|^Name:.*|Name: $PKGNAME|" $SPEC

PRODUCT=deepseek-harness-desktop
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# upstream installs into the path with a space
move_to_opt "/usr/lib/DSH Tauri"
# the binary looks for its resources in /usr/lib/<productName>
pack_file "/usr/lib/DSH Tauri"
ln -s $PRODUCTDIR "$BUILDROOT/usr/lib/DSH Tauri"

# electron runtime binary name has a space too (see runtime/*/electron-rs.json)
for rdir in $BUILDROOT$PRODUCTDIR/runtime/linux-* ; do
    [ -f "$rdir/DSH Tauri" ] || continue
    mv "$rdir/DSH Tauri" "$rdir/dsh-tauri"
    ln -s dsh-tauri "$rdir/DSH Tauri"
    rdir="${rdir#$BUILDROOT}"
    pack_file "$rdir/dsh-tauri"
    fix_chrome_sandbox "$rdir/chrome-sandbox"
done

mv "$BUILDROOT/usr/share/applications/DSH Tauri.desktop" "$BUILDROOT/usr/share/applications/$PRODUCT.desktop"
subst "s|^Name=.*|Name=Deepseek Harness|" "$BUILDROOT/usr/share/applications/$PRODUCT.desktop"
subst "s|^\"/usr/share/applications/DSH Tauri.desktop\"$|/usr/share/applications/$PRODUCT.desktop|" $SPEC

add_electron_deps
add_libs_requires

# dlopened by the tray support, zenity is used for file dialogs
add_unirequires "libayatana-appindicator3.so.1()(64bit)" zenity
