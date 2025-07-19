#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=jetbrains-toolbox
PRODUCTCUR=jetbrains-toolbox
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common.sh

# overwrite default exec script
# cat <<EOF >usr/bin/$PRODUCT
# #!/bin/sh
# BINDIR=~/.local/share/JetBrains/Toolbox/bin
# if [ ! -L \$BINDIR ] ; then
#     mkdir -p \$(dirname \$BINDIR)
#     rm -rf \$BINDIR
#     ln -s $PRODUCTDIR \$BINDIR
# fi
# cd \$BINDIR
# exec ./$PRODUCT "\$@"
# EOF

add_bin_exec_command $PRODUCT $PRODUCTDIR/$PRODUCT

add_requires java-openjdk

add_libs_requires
