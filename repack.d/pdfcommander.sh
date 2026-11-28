#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=pdfcommander
PRODUCTDIR=/usr/lib64/pdfcommander

. $(dirname $0)/common.sh

# The original postinstall script only runs update-desktop-database and update-mime-database
# (done by file triggers). The binary uses hardcoded /usr/share/pdfcommander, so keep the vendor layout.

# rpmbuild can't package files with '[wght]' in the name (glob pattern in the file list),
# the program loads all *.ttf from the Fonts dir, so just rename them
for font in "$BUILDROOT"/usr/share/pdfcommander/Fonts/*'[wght].ttf' ; do
    [ -f "$font" ] || continue
    mv -v "$font" "$(echo "$font" | sed -e 's|\[wght\]\.ttf$|-wght.ttf|')"
done
subst 's|\[wght\]\.ttf"$|-wght.ttf"|' $SPEC

# duplicate of /usr/share/applications/pdfcommander.desktop
remove_file /usr/share/pdfcommander/pdfcommander.desktop

# GTK2 application: the original package requires gnome-themes-standard (Adwaita GTK2 theme)
add_unirequires gnome-themes-standard

# loaded via dlopen: printing and OCR
add_unirequires "libcups.so.2()(64bit)" "libtesseract.so.5()(64bit)"
