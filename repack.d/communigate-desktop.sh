#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=communigate-desktop
PRODUCTDIR=/opt/communigate-desktop

. $(dirname $0)/common.sh

# The package has no maintainer scripts.
# Flutter application with an embedded CEF (libcef.so) webview.

# leftover of the vendor build
remove_file $PRODUCTDIR/lib/libflutter_linux_gtk.so.orig

# the vendor desktop file runs the app via env GTK_IM_MODULE=""
cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
export GTK_IM_MODULE=''
exec $PRODUCTDIR/cg_app "\$@"
EOF
subst "s|^Exec=.*|Exec=$PRODUCT %U|" $BUILDROOT/usr/share/applications/$PRODUCT.desktop

fix_chrome_sandbox $PRODUCTDIR/lib/chrome-sandbox

# used by the original package: file dialogs (CEF) and the portal FileChooser
add_unirequires zenity xdg-desktop-portal-gtk

# loaded via dlopen: Flutter aborts with 'No GL implementation is available' without them
add_unirequires "libEGL.so.1()(64bit)" "libGLESv2.so.2()(64bit)"
