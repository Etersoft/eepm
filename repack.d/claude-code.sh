#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=claude
PRODUCTDIR=/opt/claude.ai
PRODUCTALT="claude-code claude-code-latest"

. $(dirname $0)/common.sh

for i in $PRODUCTALT ; do
    [ "$i" = "$PKGNAME" ] && continue
    add_conflicts $i
done

CONFIGDIR=/etc/opt/claude.ai

cat <<EOF | create_file $CONFIGDIR/env.conf
# Claude Code environment configuration
CLAUDE_CODE_DISABLE_AUTO_UPDATE=1
DISABLE_AUTOUPDATER=1
CLAUDE_NO_DIAGNOSTICS=1
EOF
mark_config_noreplace $CONFIGDIR/env.conf

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
CLAUDE_CONFIG="$CONFIGDIR/env.conf"
if [ -f "\$CLAUDE_CONFIG" ]; then
    set -a
    . "\$CLAUDE_CONFIG"
    set +a
fi
CLAUDE_USER_CONFIG="\$HOME/.claude/env.conf"
if [ -f "\$CLAUDE_USER_CONFIG" ]; then
    set -a
    . "\$CLAUDE_USER_CONFIG"
    set +a
fi
[ -n "\$TMPDIR" ] && export CLAUDE_CODE_TMPDIR="\$TMPDIR"
exec $PRODUCTDIR/$PRODUCT "\$@"
EOF

