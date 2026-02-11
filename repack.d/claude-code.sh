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

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
export CLAUDE_CODE_DISABLE_AUTO_UPDATE=1
export DISABLE_AUTOUPDATER=1
export CLAUDE_NO_DIAGNOSTICS=1
[ -n "\$TMPDIR" ] && export CLAUDE_CODE_TMPDIR="\$TMPDIR"
exec $PRODUCTDIR/$PRODUCT "\$@"
EOF

