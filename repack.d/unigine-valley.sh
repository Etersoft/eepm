#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=unigine-valley
PRODUCTDIR=/opt/unigine-valley

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Graphics|" $SPEC
subst "s|^License: unknown$|License: Proprietary|" $SPEC
subst "s|^URL:.*|URL: https://benchmark.unigine.com/valley|" $SPEC
subst "s|^Summary:.*|Summary: Unigine Valley (Unigine Benchmark)|" $SPEC

mkdir -p $BUILDROOT$PRODUCTDIR/
for i in bin data documentation ; do
    mv $BUILDROOT/$i $BUILDROOT$PRODUCTDIR/$i
    subst "s|\"/$i/|\"$PRODUCTDIR/$i/|" $SPEC
done
remove_file /valley

# support only x86_64
cd $BUILDROOT/$PRODUCTDIR/bin || fatal
for i in *x86* ; do
    [ -d $i ] && remove_dir $PRODUCTDIR/bin/$i && continue
    remove_file $PRODUCTDIR/bin/$i
done

pack_dir $PRODUCTDIR
pack_dir $PRODUCTDIR/bin


add_bin_link_command $PRODUCT /usr/bin/valley

epm assure patchelf || exit

for i in *_x64 lib*_x64.so* ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done


mkdir -p $BUILDROOT/usr/bin
cat <<EOF >$BUILDROOT/usr/bin/valley
#!/bin/sh
cd $PRODUCTDIR/bin
export LD_LIBRARY_PATH=./x64:\$LD_LIBRARY_PATH
./browser_x64 -config ../data/launcher/launcher.xml
EOF
chmod a+x $BUILDROOT/usr/bin/valley
pack_file /usr/bin/valley

install_file $PRODUCTDIR/data/launcher/icon.png /usr/share/pixmaps/$PRODUCT.png

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=Unigine Valley 2013
Type=Application
Icon=$PRODUCT
Exec=valley
Terminal=false
EOF

pack_file /usr/share/applications/$PRODUCT.desktop
