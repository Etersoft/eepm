#!/bin/sh -x

# Repack sabycenter.rpm. Path contains a SPACE: /opt/Tensor/Saby Center
# Maintainer scripts replaced by:
#   - move temp_sabycenter/* into target dir
#   - drop sbis-daemon-setup.sh invocation — ship our own SabyCenter.service unit
#     (sanitized: PIDDir mode 0755 instead of 777; no nginx integration)
#   - drop /etc/abrt/abrt.conf modifications (security: lowered GPG checks)

BUILDROOT="$1"
SPEC="$2"

PRODUCT=sabycenter
PRODUCTCUR="Saby Center"
PRODUCTBASEDIR=/opt/Tensor
PRODUCTDIR="/opt/Tensor/Saby Center"

. $(dirname $0)/common.sh

# Move all from temp_sabycenter/ into PRODUCTDIR/
move_dir "$PRODUCTDIR/temp_sabycenter" "$PRODUCTDIR"

awk '/^%dir/ {key=$0; gsub(/"/,"",key); gsub(/\/+$/,"",key); if (seen[key]++) next} {print}' "$SPEC" > "$SPEC.dedup" && mv "$SPEC.dedup" "$SPEC"

# /usr/bin/sabycenter launcher symlink
add_bin_link_command sabycenter "$PRODUCTDIR/sabycenter"

# systemd unit for SabyCenter daemon. Equivalent to what
# `sbis-daemon-setup.sh --daemon-name SabyCenter --executable-name sabycenter \
#   --directory "/opt/Tensor/Saby Center" --library auto --ep auto --autorun install`
# would generate, minus security smells (chmod 777, eval, killall).
cat <<EOF | create_file /usr/lib/systemd/system/SabyCenter.service
[Unit]
Description=SBIS Service (Saby Center)
After=network.target network-online.target

[Service]
Type=forking
User=root
PermissionsStartOnly=true
ExecStartPre=-/usr/bin/mkdir -p /var/run/sbis
ExecStartPre=/usr/bin/chmod 0755 /var/run/sbis
PIDFile=/var/run/sbis/SabyCenter.pid
ExecStart="$PRODUCTDIR/sabycenter" --name "SabyCenter" --library "auto" --ep "auto" --pidfile "/var/run/sbis/SabyCenter.pid" start --daemon
ExecStop="$PRODUCTDIR/sabycenter" --name "SabyCenter" stop
WorkingDirectory=$PRODUCTDIR
Restart=always
RestartSec=3600
LimitNOFILE=1000000
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF
