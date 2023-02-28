#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=synology-drive
PRODUCTDIR=/opt/Synology/SynologyDrive


. $(dirname $0)/common.sh

cd $BUILDROOT/$PRODUCTDIR || exit

# disable autoupdate
remove_file $PRODUCTDIR/package/cloudstation/bin/cloud-drive-auto-updater

epm assure patchelf || exit
for i in lib/lib*.so.* package/cloudstation/lib/lib*.so.* ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done

# /opt/Synology/SynologyDrive/package/cloudstation/lib/plugins/designer/libqquickwidget.so
for i in package/cloudstation/lib/plugins/designer/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN../../' $i
done

for i in bin/launcher package/cloudstation/bin/cloud-drive-* ; do
    a= patchelf --set-rpath '$ORIGIN/../lib' $i
done

# TODO: some dependency leak?
# ignore embedded libs
filter_from_requires libQt5

epm install --skip-installed coreutils glib2 libdbus libgtk+3 libICE libpango libSM libX11 libxcb libxkbcommon libXrender
# libfontconfig1 libfreetype 
# Suggests
# epm install --skip-installed libnautilus libnautilus-extension-compat
filter_from_requires libnautilus

remove_file /usr/lib/nautilus/extensions-4/libnautilus-drive-extension-4.so

# fix ALT p10 install (TODO: restore for Sisyphus)
#   synology-drive: Depends: libc.so.6(GLIBC_2.33)(64bit) but it is not installable
#                  Depends: libc.so.6(GLIBC_2.34)(64bit) but it is not installable
#                  Depends: libstdc++.so.6(GLIBCXX_3.4.29)(64bit) but it is not installable
remove_file $PRODUCTDIR/package/cloudstation/icon-overlay/14/lib/plugin-cb-4.so
# skip nautilus support
remove_file $PRODUCTDIR/package/cloudstation/icon-overlay/14/lib/plugin-cb.so
# TODO: parse
# https://www.synology.com/api/support/findDownloadInfo?lang=ru-ru&product=DS2411%2B&major=6&minor=2
