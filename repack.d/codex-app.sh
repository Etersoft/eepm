#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

move_to_opt

rm -v usr/bin/$PRODUCT

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
$PRODUCTDIR/$PRODUCT --ozone-platform=x11
EOF
