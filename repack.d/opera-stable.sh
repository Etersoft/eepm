#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=opera
PRODUCTCUR0=$(basename $0 .sh)
PRODUCTCUR=$(basename $0 .sh)
[ "$PRODUCTCUR" = "$PRODUCT-stable" ] && PRODUCTCUR=$PRODUCT
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common-chromium-browser.sh

for i in opera-stable opera-beta opera-developer ; do
    [ "$i"  = "$PRODUCTCUR0" ] && continue
    subst "1iConflicts:$i" $SPEC
done

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

#if epm installed ffmpeg-plugin-browser ; then
#    libffmpeg="$(epm -ql ffmpeg-plugin-browser | grep libfmpeg.so)" || fatal
#fi
# test with https://archive.org/details/H265_Test
cat <<EOF >$BUILDROOT$PRODUCTDIR/resources/ffmpeg_preload_config.json
[
  "/usr/lib64/ffmpeg-plugin-browser/libffmpeg.so",
  "/opt/chromium-browser/libffmpeg.so",
  "../../../../chromium-ffmpeg/libffmpeg.so",
  "/usr/lib/chromium-browser/libffmpeg.so",
  "/usr/lib/chromium-browser/libs/libffmpeg.so"
]
EOF

# alternative way
#mkdir -p $BUILDROOT$PRODUCTDIR/lib_extra/
#ln -s /opt/chromium-browser/libffmpeg.so $BUILDROOT$PRODUCTDIR/lib_extra/libffmpeg.so
#pack_file $PRODUCTDIR/lib_extra/libffmpeg.so

#rm -fv $BUILDROOT/usr/bin/$PRODUCTCUR
add_bin_commands

fix_chrome_sandbox $PRODUCTDIR/opera_sandbox

# TODO: it is possible we will not require this if link bin->/opt/dir/name is relative
# fix to support pack links in /usr/bin (may be this is a bug?)
if epm assure patchelf ; then
for i in $BUILDROOT$PRODUCTDIR/$PRODUCTCUR ; do
    a= patchelf --set-rpath "$PRODUCTDIR/lib_extra:$PRODUCTDIR" $i
done
fi

#subst '1iRequires: chromium-codecs-ffmpeg-extra >= 103' $SPEC

install_deps

