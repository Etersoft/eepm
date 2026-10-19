#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=activinspire
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# Version: 3.5.18.2004-1.amd64 (2004 is Ubuntu 20.04)
VERSION="$(grep '^Version:' $SPEC | sed -e 's|^Version:[[:space:]]*||' -e 's|\.2004$||')"
subst "s|^Version:.*|Version: $VERSION|" $SPEC
subst "s|^\(Release:.*\)\.amd64$|\1|" $SPEC

# shared settings and resources, all users write there (as in the vendor's postinst)
for i in /etc/xdg/Promethean /var/Promethean ; do
    subst "s|^%dir \"$i/*\"$|%attr(0777,root,root) %dir \"$i\"|" $SPEC
    subst "s|^%dir $i/*$|%attr(0777,root,root) %dir $i|" $SPEC
done

move_to_opt /usr/local/bin/activsoftware
# the vendor's launchers use bash and an obsolete compositing workaround
remove_dir /usr/local

# Qt5 leftovers, nothing uses them (the application is built with bundled Qt6)
for i in libappcontroller libatlascomms libqtatlascomms libscreenrec ; do
    remove_file "$PRODUCTDIR/$i.so*"
done

# Qt build tools and debug info
for i in cmake_automoc_parser ensure_pro_file.cmake gn lprodump lrelease-pro lupdate-pro moc qlalr \
         qmlcachegen qmlimportscanner qmltyperegistrar qt-internal-configure-tests qtattributionsscanner \
         qtwaylandscanner qvkgen qwebengine_convert_dict rcc repc syncqt.pl tracegen uic \
         android_emulator_launcher.sh libQt6Pdf.so.5.9.0.debug ; do
    remove_file "$PRODUCTDIR/$i"
done

# GNOME Shell 3.36/40 extension, does not work with the current GNOME
remove_dir "/usr/share/gnome-shell/extensions/enable-multitouch-in-activInspire@prometheanworld.com"
remove_dir /usr/share/gnome-shell/extensions
remove_dir /usr/share/gnome-shell

# disables compositing via compiz/metacity/gconftool-2, obsolete
remove_file /usr/share/applications/activsoftware-nc.desktop

# QtWebEngineCore needs libre2.so.5 (Ubuntu 20.04), ALT's libre2.so.10 lacks some of its symbols
RE2URL="http://archive.ubuntu.com/ubuntu/pool/main/r/re2/libre2-5_20200101+dfsg-1build1_amd64.deb"
tmpdir="$(mktemp -d)" || fatal
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM
epm tool eget -O "$tmpdir/libre2.deb" "$RE2URL" || fatal "Can't download $RE2URL"
epm tool erc -C "$tmpdir/libre2" unpack "$tmpdir/libre2.deb" || fatal
cp -a "$tmpdir/libre2/usr/lib/x86_64-linux-gnu/libre2.so.5" "$tmpdir/libre2/usr/lib/x86_64-linux-gnu/libre2.so.5.0.0" "$BUILDROOT$PRODUCTDIR/" || fatal
pack_file "$PRODUCTDIR/libre2.so.5"
pack_file "$PRODUCTDIR/libre2.so.5.0.0"

# libwebp.so.7 is ABI compatible for the symbols used
a='' patchelf --replace-needed libwebp.so.6 libwebp.so.7 "$BUILDROOT$PRODUCTDIR/libQt6WebEngineCore.so.6.2.1" || fatal

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
cd $PRODUCTDIR || exit
export LD_LIBRARY_PATH="$PRODUCTDIR\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
export QTWEBENGINEPROCESS_PATH="$PRODUCTDIR/QtWebEngineProcess"
# stale semaphore after a crash prevents start
rm -f /dev/shm/sem.promethean 2>/dev/null
# Inspire crashes in XrmGetStringDatabase(NULL) if the X server has no resources (RESOURCE_MANAGER)
if [ -n "\$DISPLAY" ] && [ -z "\$(xrdb -query 2>/dev/null)" ] ; then
    echo 'Inspire.eepm: 1' | xrdb -nocpp -merge 2>/dev/null
fi
exec ./Inspire "\$@"
EOF

cat <<EOF | create_exec_file /usr/bin/activplayer
#!/bin/sh
cd $PRODUCTDIR || exit
export LD_LIBRARY_PATH="$PRODUCTDIR\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec ./activplayer "\$@"
EOF

fix_desktop_file /usr/local/bin/inspire $PRODUCT
fix_desktop_file /usr/local/bin/activityplayer activplayer
fix_desktop_file /usr/share/icons/hicolor/48x48/apps/asstudio.png asstudio
fix_desktop_file /usr/share/icons/hicolor/48x48/apps/activplayer.png activplayer
# typo in the vendor's file
subst 's|x-sheme-handler|x-scheme-handler|' $BUILDROOT/usr/share/applications/activsoftware.desktop
