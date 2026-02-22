#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=claude-code-webui
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

CONFIGDIR=/etc/opt/$PRODUCT

cat <<EOF | create_file $CONFIGDIR/env.conf
# Claude Code WebUI environment configuration
CLAUDE_CODE_DISABLE_AUTO_UPDATE=1
CLAUDE_NO_DIAGNOSTICS=1
EOF

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
CLAUDE_CONFIG="$CONFIGDIR/env.conf"
if [ -f "\$CLAUDE_CONFIG" ]; then
    set -a
    . "\$CLAUDE_CONFIG"
    set +a
fi
exec $PRODUCTDIR/$PRODUCT "\$@"
EOF
