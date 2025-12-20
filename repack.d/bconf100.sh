#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=bconf100
PRODUCTDIR=/opt/ecores/$PRODUCT

. $(dirname $0)/common.sh

install_file /usr/share/ecores/bconf100/bconf100.desktop /usr/share/applications/$PRODUCT.desktop

move_to_opt /usr/share/ecores/bconf100
remove_dir /usr/share/mime/icons

# FiXME
#install_file /usr/share/ecores/settings.ini $PRODUCTDIR/../settings.ini

fix_desktop_file /usr/share/ecores/bconf100/bconf100.ico $PRODUCT
fix_desktop_file "env LD_LIBRARY_PATH=/usr/share/ecores/bconf100/ /usr/share/ecores/bconf100/bconf100" $PRODUCT

subst "s|/usr/share/ecores/bconf100|$PRODUCTDIR|" .$PRODUCTDIR/$PRODUCT.sh
add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT.sh

if false ; then
cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
if [ "\$LD_LIBRARY_PATH" ]; then
	export LD_LIBRARY_PATH="$PRODUCTDIR:\$LD_LIBRARY_PATH"
else
	export LD_LIBRARY_PATH="$PRODUCTDIR"
fi
$PRODUCTDIR/$PRODUCT "\$@"
EOF
fi


