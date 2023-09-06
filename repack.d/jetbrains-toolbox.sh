#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=jetbrains-toolbox
PRODUCTCUR=jetbrains-toolbox
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Development/C|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://www.jetbrains.com/ru-ru/toolbox-app/|" $SPEC
subst "s|^Summary:.*|Summary: JetBrains Toolbox App|" $SPEC


# overwrite default exec script
cat <<EOF >usr/bin/$PRODUCT
#!/bin/sh
BINDIR=~/.local/share/JetBrains/Toolbox/bin
if [ ! -L \$BINDIR ] ; then
    mkdir -p \$(dirname \$BINDIR)
    rm -rf \$BINDIR
    ln -s $PRODUCTDIR \$BINDIR
fi
cd \$BINDIR
exec ./$PRODUCT "\$@"
EOF

add_requires java-openjdk

# set_autoreq 'yes'
add_libs_requires
