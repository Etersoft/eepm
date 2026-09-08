#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=codexbar
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_requires libcurl4-openssl
cat <<'EOF' | create_exec_file "/usr/bin/$PRODUCT"
#!/bin/sh
export LD_LIBRARY_PATH=/usr/lib64/libcurl4-openssl${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
exec /opt/codexbar/codexbar "$@"
EOF
