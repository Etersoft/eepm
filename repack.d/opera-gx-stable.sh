#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=opera-gx
PRODUCTCUR=opera-gx-stable
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common-chromium-browser.sh

set_alt_alternatives 65

move_to_opt "/usr/lib/*/$PRODUCTCUR" "/usr/lib*/$PRODUCTCUR"

cleanup
remove_dir /usr/share/menu
remove_dir /usr/share/lintian
remove_dir /usr/share/mime
remove_dir /usr/lib

remove_file $PRODUCTDIR/opera_autoupdate.licenses
remove_file $PRODUCTDIR/opera_autoupdate.version
remove_file $PRODUCTDIR/opera_autoupdate
remove_file $PRODUCTDIR/setup_repo.sh

cat <<EOF >$BUILDROOT$PRODUCTDIR/resources/ffmpeg_preload_config.json
[
  "/usr/lib64/ffmpeg-plugin-browser/libffmpeg.so",
  "/opt/chromium-browser/libffmpeg.so",
  "../../../../chromium-ffmpeg/libffmpeg.so",
  "/usr/lib/chromium-browser/libffmpeg.so",
  "/usr/lib/chromium-browser/libs/libffmpeg.so"
]
EOF

# the binary inside the package is plain "opera"; recreate /usr/bin/opera-gx and add opera-gx-stable alias
rm -f $BUILDROOT/usr/bin/$PRODUCT
ln -rs $BUILDROOT$PRODUCTDIR/opera $BUILDROOT/usr/bin/$PRODUCT
add_bin_link_command $PRODUCTCUR $PRODUCTDIR/opera

fix_chrome_sandbox $PRODUCTDIR/opera_sandbox

add_chromium_deps
