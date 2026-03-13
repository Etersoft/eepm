#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=cursor-agent
PRODUCTDIR=/opt/cursor-agent

. $(dirname $0)/common.sh

cat <<EOF | create_exec_file /usr/bin/cursor-agent
#!/bin/sh
exec $PRODUCTDIR/cursor-agent "\$@"
EOF
