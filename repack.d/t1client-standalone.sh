#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=t1client
PRODUCTDIR=/opt/dssl/t1client

. $(dirname $0)/common-chromium-browser.sh

# generic.sh prepends a python3 shebang to every *.py in BUILDROOT.
# That breaks TRASSIR's signed vendor bundle: vendor.sign no longer matches
# vendor/DSSL/scripts-stock/pacs-client.py, and the client aborts on startup.
# Restore the upstream file contents for the bundled Python trees.
find "$BUILDROOT$PRODUCTDIR" -type f -name '*.py' \
    -exec sed -i -e '1{/^#!\/usr\/bin\/python3$/d;}' '{}' \;

add_bin_link_command $PRODUCT $PRODUCTDIR/run_t1client.sh

fix_desktop_file /opt/dssl/t1client/run_t1client.sh $PRODUCT

# Keep the bundled dependencies/ runtime: it carries the old Qt/ffmpeg/boost
# stack the client actually links against. Only strip clearly optional modules
# inside it that pull in dead legacy dependencies on ALT.
QT4PLUGINDIR="$PRODUCTDIR/dependencies/lib64/qt4/plugins"
PYTHON27DIR="$PRODUCTDIR/dependencies/lib64/python2.7"

for dir in \
    "$QT4PLUGINDIR/designer" \
    "$QT4PLUGINDIR/qmltooling" \
    "$PYTHON27DIR/site-packages/rpm"
do
    remove_dir "$dir"
done

for file in \
    "$QT4PLUGINDIR/script/libqtscriptdbus.so" \
    "$QT4PLUGINDIR/imageformats/libqmng.so" \
    "$QT4PLUGINDIR/imageformats/libqtiff.so" \
    "$QT4PLUGINDIR/accessible/libqtaccessiblecompatwidgets.so" \
    "$QT4PLUGINDIR/sqldrivers/libqsqlmysql.so" \
    "$PYTHON27DIR/lib-dynload/gdbmmodule.so" \
    "$PYTHON27DIR/lib-dynload/dbm.so" \
    "$PYTHON27DIR/lib-dynload/readline.so" \
    "$PYTHON27DIR/site-packages/numpy/linalg/lapack_lite.so" \
    "$PYTHON27DIR/site-packages/numpy/core/_dotblas.so" \
    "$PYTHON27DIR/site-packages/Crypto/Cipher/_DES.so" \
    "$PYTHON27DIR/site-packages/Crypto/Cipher/_DES3.so" \
    "$PYTHON27DIR/site-packages/talloc.so" \
    "$PYTHON27DIR/site-packages/sepolicy/policy.so" \
    "$PYTHON27DIR/site-packages/_semanage.so"
do
    remove_file "$file"
done

# Optional legacy capture helpers ship another obsolete dependency tail
# (old ffmpeg/opencv/boost/openssl sonames) that is not installable on ALT.
for dir in \
    "$PRODUCTDIR/subgrabhcnet" \
    "$PRODUCTDIR/subgrabhcnetv5"
do
    remove_dir "$dir"
done

remove_file "$PRODUCTDIR/lib32/libStreamTransClient.so"

# disable auto req
#ignore_lib_requires 'libmng.so.1'
#add_libs_requires
