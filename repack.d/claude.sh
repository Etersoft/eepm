#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=claude
PRODUCTDIR=/opt/claude.ai

. $(dirname $0)/common.sh

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
export CLAUDE_CODE_DISABLE_AUTO_UPDATE=1
export CLAUDE_NO_DIAGNOSTICS=1
exec $PRODUCTDIR/$PRODUCT "\$@"
EOF

