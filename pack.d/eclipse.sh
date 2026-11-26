#!/bin/sh

# Pack an Eclipse IDE EPP package (any edition) into eclipse-<edition>.
# The tarball is self-contained: it bundles JRE (JustJ) and the SWT GTK libraries.

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# eclipse-<edition>-<YYYY>-<MM>-R-linux-gtk-<arch>.tar.gz
name="$(basename "$TAR")"
EDITION="$(echo "$name" | sed -n 's|^eclipse-\([a-z]*\)-[0-9]*-[0-9]*-R-linux-gtk-.*\.tar\.gz$|\1|p')"
VERSION="$(echo "$name" | sed -n 's|^eclipse-[a-z]*-\([0-9]*\)-\([0-9]*\)-R-linux-gtk-.*\.tar\.gz$|\1.\2|p')"
ARCH="$(echo "$name" | sed -n 's|.*-linux-gtk-\(.*\)\.tar\.gz$|\1|p')"
[ -n "$EDITION" ] && [ -n "$VERSION" ] && [ -n "$ARCH" ] || fatal "Can't parse Eclipse edition, release and arch from $name"

PRODUCT="eclipse-$EDITION"
PRODUCTDIR="opt/$PRODUCT"

erc --here unpack "$TAR" || fatal
[ -x eclipse/eclipse ] || fatal "There is no eclipse/eclipse launcher in $name"
mkdir -p opt || fatal
mv eclipse "$PRODUCTDIR" || fatal

# Plugins (JNA, jffi and others) ship native libraries for all platforms, which give
# unsatisfiable requires (libc.so.7, libthr.so.3, 32-bit libc.so.6).
# Keep only ELF files for Linux (OS/ABI SYSV or GNU/Linux) on the current machine.
case "$ARCH" in
    x86_64) elfmachine=62 ;;
    aarch64) elfmachine=183 ;;
    riscv64) elfmachine=243 ;;
    *) fatal "Unsupported arch $ARCH" ;;
esac

# print "<OS/ABI> <machine>" from the ELF header, or nothing for a non-ELF file
elf_osabi_machine()
{
    [ "$(od -An -c -N4 "$1" | tr -d ' ')" = "177ELF" ] || return
    echo "$(od -An -tu1 -j7 -N1 "$1") $(od -An -tu2 -j18 -N2 "$1")"
}

# keep a native library if it is an ELF for Linux on the current machine
is_native_lib_for_us()
{
    # some BSD and Solaris builds have OS/ABI SYSV, so check the OS name in the path too
    echo "${1#$PRODUCTDIR/plugins/}" | grep -qiE 'sunos|solaris|freebsd|openbsd|netbsd|dragonfly|darwin|macos|win32|windows|aix' && return 1
    case "$1" in
        *.so|*.so.*) ;;
        *) return 1 ;;
    esac
    set -- $(elf_osabi_machine "$1")
    [ "$2" = "$elfmachine" ] || return 1
    [ "$1" = 0 ] || [ "$1" = 3 ]
}

find "$PRODUCTDIR/plugins" -type f \( -name '*.so' -o -name '*.so.*' -o -name '*.dll' -o -name '*.dylib' -o -name '*.jnilib' \) | while IFS= read -r i ; do
    is_native_lib_for_us "$i" || rm "$i" || fatal
done

mkdir -p usr/bin || fatal
ln -s "/$PRODUCTDIR/eclipse" "usr/bin/$PRODUCT" || fatal
# eclipse command is for the default edition only, so the editions can be installed together
[ "$EDITION" = "java" ] && { ln -s "$PRODUCT" usr/bin/eclipse || fatal ; }

icon="$(ls "$PRODUCTDIR"/plugins/org.eclipse.platform_*/eclipse256.png 2>/dev/null | head -n1)"
[ -n "$icon" ] && install -D -m644 "$icon" "usr/share/icons/hicolor/256x256/apps/$PRODUCT.png"

mkdir -p usr/share/applications || fatal
cat <<EOF >"usr/share/applications/$PRODUCT.desktop"
[Desktop Entry]
Type=Application
Name=Eclipse IDE ($EDITION)
Comment=Eclipse IDE for $EDITION development
Exec=$PRODUCT %F
Icon=$PRODUCT
Terminal=false
Categories=Development;IDE;
StartupNotify=true
StartupWMClass=Eclipse
EOF

PKGNAME="$PRODUCT-$VERSION"

erc pack "$PKGNAME.tar" opt usr || fatal

cat <<EOF >"$PKGNAME.tar.eepm.yaml"
name: $PRODUCT
version: $VERSION
group: Development/Tools
license: EPL-2.0
url: https://eclipseide.org/
summary: Eclipse IDE ($EDITION edition)
description: Eclipse IDE ($EDITION edition) from the official site, with the bundled JRE.
EOF

return_tar "$PKGNAME.tar"
