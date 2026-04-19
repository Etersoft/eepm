#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=karing
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

move_to_opt /usr/share/karing

# crashpad helper must be executable at runtime
[ -f "$BUILDROOT$PRODUCTDIR/lib/crashpad_handler" ] && chmod 0755 "$BUILDROOT$PRODUCTDIR/lib/crashpad_handler"

# karing bundles its own JRE under /opt/karing, so host libjvm should not be required.
ignore_lib_requires "libjvm.so()(64bit)" "libjli.so()(64bit)" "libjava.so()(64bit)"

# Add dependency on libcurl4-openssl
add_requires "libcurl4-openssl"

# Create wrapper script instead of direct link for libcurl4-openssl compatibility
cat <<EOF | create_exec_file "/usr/bin/karing"
#!/bin/sh
export LD_LIBRARY_PATH="/usr/lib64/libcurl4-openssl:\$LD_LIBRARY_PATH"
exec "$PRODUCTDIR/karing" "\$@"
EOF

fix_desktop_file "Categories=Applications/Internet;" "Categories=Network;Internet;"
