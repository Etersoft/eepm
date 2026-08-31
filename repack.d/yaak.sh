#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yaak
# Yaak has absolute /usr/lib/yaak paths compiled in for its plugin runtime and bundled resources.
PRODUCTDIR=/usr/lib/$PRODUCT

. $(dirname $0)/common.sh

move_file /usr/bin/yaak-app-client $PRODUCTDIR/yaak-app-client

cat <<EOF | create_exec_file /usr/bin/yaak-app-client
#!/bin/sh
if [ -z "\$SSL_CERT_FILE" ] && [ -r /etc/pki/tls/certs/ca-bundle.crt ] ; then
    export SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt
fi
exec $PRODUCTDIR/yaak-app-client "\$@"
EOF
