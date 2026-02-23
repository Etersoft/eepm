#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

#remove garbage from version in spec
sed -i -e 's/^\(Version: [^+]*\)+.*/\1/' $SPEC

move_to_opt

# libsentry.so requires CURL_OPENSSL_4, but system libcurl provides CURL_GNUTLS_4
ignore_lib_requires libcurl.so.4
add_requires libcurl4-openssl
cat <<'EOF' | create_exec_file "/usr/bin/hiddify"
#!/bin/sh
export LD_LIBRARY_PATH=/usr/lib64/libcurl4-openssl${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
exec /opt/hiddify/hiddify "$@"
EOF

