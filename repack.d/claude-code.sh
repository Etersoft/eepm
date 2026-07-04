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
if [ -r "\$CLAUDE_CONFIG" ]; then
    set -a
    . "\$CLAUDE_CONFIG"
    set +a
fi
CLAUDE_USER_CONFIG="\$HOME/.claude/env.conf"
if [ -r "\$CLAUDE_USER_CONFIG" ]; then
    set -a
    . "\$CLAUDE_USER_CONFIG"
    set +a
fi
[ -n "\$TMPDIR" ] && export CLAUDE_CODE_TMPDIR="\$TMPDIR"

# provide a user-local convenience symlink ~/.local/bin/claude -> /usr/bin/claude,
# but never overwrite an existing entry (file or symlink, even a dangling one)
CLAUDE_LOCAL_LINK="\$HOME/.local/bin/claude"
if [ ! -e "\$CLAUDE_LOCAL_LINK" ] && [ ! -L "\$CLAUDE_LOCAL_LINK" ]; then
    mkdir -p "\$HOME/.local/bin" 2>/dev/null
    ln -s /usr/bin/claude "\$CLAUDE_LOCAL_LINK" 2>/dev/null
fi

exec $PRODUCTDIR/$PRODUCT "\$@"
EOF

