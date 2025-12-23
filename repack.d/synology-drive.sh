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

# they miss libQt5Pdf.so.5
remove_file $PRODUCTDIR/plugins/imageformats/libqpdf.so
remove_file $PRODUCTDIR/package/cloudstation/lib/plugins/imageformats/libqpdf.so

# libQt5Sql.so.5()(64bit)
remove_file $PRODUCTDIR/package/cloudstation/lib/plugins/sqldrivers/libqsqlite.so
# libQt5QuickWidgets.so.5()(64bit)
remove_file $PRODUCTDIR/package/cloudstation/lib/plugins/designer/libqquickwidget.so

# libQt5Quick.so.5()(64bit)
# libQt5Qml.so.5()(64bit)
remove_dir $PRODUCTDIR/package/cloudstation/lib/plugins/qmltooling/
#remove_file $PRODUCTDIR/package/cloudstation/lib/plugins/qmltooling/libqmldbg_inspector.so
#remove_file $PRODUCTDIR/package/cloudstation/lib/plugins/qmltooling/libqmldbg_preview.so
#remove_file $PRODUCTDIR/package/cloudstation/lib/plugins/qmltooling/libqmldbg_quickprofiler.so

# support install on p10 or KDE based
ignore_lib_requires libnautilus-extension.so.4

# support install on p11 or KDE based
ignore_lib_requires libnautilus-extension.so.1

move_file /usr/lib/nautilus/extensions-4/libnautilus-drive-extension-4.so /usr/lib64/nautilus/extensions-4/libnautilus-drive-extension-4.so
# don't support legacy
remove_file /usr/lib/nautilus/extensions-3.0/libnautilus-drive-extension.so
# deb systems only
remove_file /usr/lib/x86_64-linux-gnu/nautilus/extensions-4/libnautilus-drive-extension.so

remove_dir /usr/lib
remove_dir /usr/lib/x86_64-linux-gnu/

# old nautilus
remove_file $PRODUCTDIR/package/cloudstation/icon-overlay/15/lib/plugin-cb.so || :

# TODO: parse
# https://www.synology.com/api/support/findDownloadInfo?lang=ru-ru&product=DS2411%2B&major=6&minor=2

