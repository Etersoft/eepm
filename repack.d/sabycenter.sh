#!/bin/sh -x

# Repack sabycenter.rpm. Path contains a SPACE: /opt/Tensor/Saby Center
# Maintainer scripts replaced by:
#   - move temp_sabycenter/* into target dir
#   - drop systemd service registration (sbis-daemon-setup.sh) — handled by play.d
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
