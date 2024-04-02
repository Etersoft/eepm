#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=atom
#PRODUCTCUR=atom-beta
PRODUCTCUR=$(basename $0 .sh)
APMNAME=$(echo $PRODUCTCUR | sed -e 's|^atom|apm|')

. $(dirname $0)/common-chromium-browser.sh

for i in atom atom-beta ; do
    [ "$i"  = "$PRODUCTCUR" ] && continue
    add_conflicts $i
done

add_electron_deps

add_unirequires coreutils findutils grep sed /usr/bin/git /usr/bin/node /usr/bin/npm /usr/bin/npx util-linux which xprop python3

move_to_opt
subst "s|\$USR_DIRECTORY/share/atom|/opt/atom|" $BUILDROOT/usr/bin/$PRODUCTCUR
add_bin_exec_command $PRODUCT /usr/bin/$PRODUCTCUR

#rm $PRODUCTDIR/resources/app/apm/node_modules/.bin/apm
# TODO: app/apm/bin/apm?
rm -v $BUILDROOT/usr/bin/$APMNAME
add_bin_link_command $APMNAME $PRODUCTDIR/resources/app/apm/node_modules/.bin/apm

#subst '1iBuildRequires:rpm-build-python3' $SPEC
#subst "1i%add_python3_path $PRODUCTDIR" $SPEC

# replace embedded git with standalone (due Can't locate Git/LoadCPAN/Error.pm)
EMBDIR=$PRODUCTDIR/resources/app.asar.unpacked/node_modules/dugite/git
echo "Removing $BUILDROOT$EMBDIR/ ..."
remove_dir $EMBDIR
mkdir -p $BUILDROOT$EMBDIR/bin/
ln -s /usr/bin/git $BUILDROOT$EMBDIR/bin/git
pack_dir $EMBDIR
pack_dir $EMBDIR/bin
pack_file $EMBDIR/bin/git

# replace embedded npm with standalone
EMBDIR=$PRODUCTDIR/resources/app/apm/node_modules/npm
echo "Removing $BUILDROOT$EMBDIR/ ..."
remove_dir $EMBDIR
ln -s /usr/lib/node_modules/npm $BUILDROOT$EMBDIR
pack_file $EMBDIR

# replace embedded node and npm
for EMBDIR in $PRODUCTDIR/resources/app/apm/bin/{node,npm} \
              $PRODUCTDIR/resources/app/apm/node_modules/.bin/{npm,npx} \
              $PRODUCTDIR/resources/app/apm/node_modules/open/xdg-open ; do
    echo "Removing $BUILDROOT$EMBDIR ..."
    rm $BUILDROOT$EMBDIR
    ln -s /usr/bin/$(basename $EMBDIR) $BUILDROOT$EMBDIR
done

# TODO use separated chromium-sandbox
# TODO for other distros?

