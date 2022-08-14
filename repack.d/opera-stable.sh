#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=opera
PRODUCTCUR=opera
PRODUCTDIR=/opt/opera

. $(dirname $0)/common-chromium-browser.sh

#subst '1iConflicts:vivaldi-snapshot' $SPEC

set_alt_alternatives 65

move_to_opt "/usr/lib/x86_64-linux-gnu/opera"

cleanup
remove_dir /usr/share/menu
remove_dir /usr/share/lintian
remove_dir /usr/share/mime
remove_dir /usr/lib

remove_file $PRODUCTDIR/opera_autoupdate.licenses
remove_file $PRODUCTDIR/opera_autoupdate.version
remove_file $PRODUCTDIR/opera_autoupdate

cat <<EOF >$BUILDROOT/opt/opera/resources/ffmpeg_preload_config.json
[
  "/opt/chromium-browser/libffmpeg.so"
]
EOF

# alternative way
#mkdir -p $BUILDROOT$PRODUCTDIR/lib_extra/
#ln -s /opt/chromium-browser/libffmpeg.so $BUILDROOT$PRODUCTDIR/lib_extra/libffmpeg.so

add_bin_commands

fix_chrome_sandbox $PRODUCTDIR/opera_sandbox

# fix to support pack links in /usr/bin (may be this is a bug?)
epm assure patchelf || exit
for i in $BUILDROOT/$PRODUCTDIR/$PRODUCT ; do
    a= patchelf --set-rpath "$PRODUCTDIR/lib_extra:$PRODUCTDIR" $i
done

subst '1iRequires: chromium-codecs-ffmpeg-extra >= 103' $SPEC

install_deps

