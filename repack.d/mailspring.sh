#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

move_to_opt

# used by libscram.so
ignore_lib_requires libcrypto.so.1.0.0
# used by libsasldb.so
ignore_lib_requires libdb-5.3.so

add_unirequires libtidy.so.5
add_unirequires libcurl-openssl.so.4

rm -v usr/bin/$PRODUCT

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
export LD_LIBRARY_PATH=/usr/lib64/libcurl4-openssl
$PRODUCTDIR/$PRODUCT --ozone-platform=x11
EOF

#add_electron_deps

