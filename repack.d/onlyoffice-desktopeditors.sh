#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/onlyoffice

. $(dirname $0)/common.sh

# TODO: required libreoffice-opensymbol-fonts
# $ rpm -qf /usr/lib64/LibreOffice/share/fonts/truetype/opens___.ttf
#LibreOffice-common-7.0.1.2-alt1.0.p9.x86_64

# ALT only
add_requires fonts-ttf-liberation fonts-ttf-dejavu

# pack icons
iconname=onlyoffice-desktopeditors
icon_paths=""

for i in 16 22 24 32 48 64 128 256; do
    icon_src="$BUILDROOT/$PRODUCTDIR/desktopeditors/asc-de-$i.png"
    icon_dest="$BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png"

    [ -r "$icon_src" ] || continue

    mkdir -p "$(dirname "$icon_dest")"
    cp "$icon_src" "$icon_dest"

    icon_paths="/usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png\n$icon_paths"
done

subst "s|%files|%files\n${icon_paths%\\n}|" "$SPEC"

# Rename templates for compatibility with rpmbuild
find "$BUILDROOT$PRODUCTDIR/desktopeditors/converter/templates" -name '*\[*]*' | while read file; do
    newfile=$(echo "$file" | sed 's/\[//g; s/\]//g')
    mv "$file" "$newfile"
done
template_paths=$(find "$BUILDROOT$PRODUCTDIR/desktopeditors/converter/templates" -type f | sed "s|$BUILDROOT||")

subst '/\/desktopeditors\/converter\/templates\/.*\[\|\]/d' "$SPEC"

escaped_paths=$(echo "$template_paths" | sed ':a;N;$!ba;s/\n/\\n/g')
subst "s|%files|%files\n$escaped_paths|" "$SPEC"

fix_desktop_file /usr/bin/onlyoffice-desktopeditors

add_libs_requires
