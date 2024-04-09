#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

add_bin_exec_command $PRODUCT
cat <<EOF >$BUILDROOT/usr/bin/$PRODUCT
#!/bin/sh
exec $PRODUCTDIR/$PRODUCT --disable-gpu --no-sandbox "\$@"
EOF

add_libs_requires
