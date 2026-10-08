#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

erc --here unpack "$TAR" || fatal

# Codex falls back to its regular shell backend; the bundled test zsh lacks
# modules and is incompatible with ALT Linux's libtinfo.
rm -r codex-resources/zsh || fatal

# Keep the upstream package layout so Codex can find its bundled tools.
mkdir -p opt/codex
mv bin codex-package.json codex-path codex-resources opt/codex/ || fatal

# Symlinks for PATH
mkdir -p usr/bin
ln -s /opt/codex/bin/codex usr/bin/codex
ln -s /opt/codex/bin/codex-code-mode-host usr/bin/codex-code-mode-host

# Keep auto-downloaded app-server releases from accumulating in each user's home.
mkdir -p usr/lib/systemd/user
cat >usr/bin/codex-clean-old-releases <<'EOF'
#!/bin/sh
set -eu
codex_dir="$HOME/.codex/packages/app-server-daemon"
[ -d "$codex_dir/releases" ] || exit 0
codex_current=$(readlink -e "$codex_dir/current") || exit 0
[ -d "$codex_current" ] || exit 0
for release in "$codex_dir"/releases/* ; do
    [ -d "$release" ] && [ ! -L "$release" ] || continue
    [ "$release" != "$codex_current" ] || continue
    # Running older servers must survive until their processes exit.
    pgrep -u "$(id -u)" -f "$release/bin/" >/dev/null && continue
    rm -rf -- "$release"
done
EOF
chmod 755 usr/bin/codex-clean-old-releases

cat >usr/lib/systemd/user/codex-release-cleanup.service <<'EOF'
[Unit]
Description=Remove unused old Codex releases

[Service]
Type=oneshot
ExecStart=/usr/bin/codex-clean-old-releases
EOF

cat >usr/lib/systemd/user/codex-release-cleanup.timer <<'EOF'
[Unit]
Description=Clean old Codex releases daily

[Timer]
OnStartupSec=15min
OnUnitActiveSec=1d

[Install]
WantedBy=timers.target
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://github.com/openai/codex
summary: Codex CLI
description: Codex CLI is a coding agent from OpenAI that runs locally on your computer.
EOF

return_tar $PKGNAME.tar
