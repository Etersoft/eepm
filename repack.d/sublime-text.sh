#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=sublime-text
PRODUCTCUR=subl
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Text tools|" $SPEC
subst "s|^URL:.*|URL: https://www.sublimetext.com|" $SPEC
subst "s|^Summary:.*|Summary: Sophisticated text editor for code, html and prose|" $SPEC
subst "s|^License: unknown$|License: Proprietary|" $SPEC

filter_from_requires "python3(sublime_api)"

# move package to /opt
ROOTDIR=sublime_text
mkdir -p $BUILDROOT/opt
mv $BUILDROOT/$ROOTDIR $BUILDROOT$PRODUCTDIR
subst "s|\"/$ROOTDIR/|\"$PRODUCTDIR/|" $SPEC


for res in 128x128 16x16 256x256 32x32 48x48; do
    install -dm755 "$BUILDROOT/usr/share/icons/hicolor/${res}/apps"
    cp $BUILDROOT$PRODUCTDIR/Icon/${res}/sublime-text.png $BUILDROOT/usr/share/icons/hicolor/${res}/apps/sublime-text.png
    pack_file /usr/share/icons/hicolor/${res}/apps/sublime-text.png
done

# add binary to the search path
mkdir -p $BUILDROOT/usr/bin/
ln -s $PRODUCTDIR/sublime_text $BUILDROOT/usr/bin/$PRODUCT
subst "s|%files|%files\n/usr/bin/$PRODUCT|" $SPEC
ln -s $PRODUCTDIR/sublime_text $BUILDROOT/usr/bin/$PRODUCTCUR
subst "s|%files|%files\n/usr/bin/$PRODUCTCUR|" $SPEC


# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Sublime Text
GenericName=Text Editor
Comment=Sophisticated text editor for code, markup and prose
Exec=subl %F
Terminal=false
MimeType=text/plain;
Icon=sublime-text
Categories=TextEditor;Development;
StartupNotify=true
StartupWMClass=subl
Actions=Window;Document;

[Desktop Action Window]
Name=New Window
Exec=subl -n
OnlyShowIn=Unity;

[Desktop Action Document]
Name=New File
Exec=subl --command new_file
OnlyShowIn=Unity;
EOF
subst "s|%files|%files\n/usr/share/applications/$PRODUCT.desktop|" $SPEC
