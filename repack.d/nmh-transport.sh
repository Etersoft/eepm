#!/bin/sh -x

# Repack nmh-transport.rpm — Native Messaging Host for browsers (Saby plugin transport).
# Maintainer scripts replaced by:
#   - move temp_nmh/* into target dir
#   - drop components-registrator installNmh — runs from play.d/saby.sh after install,
#     so browser native-messaging-hosts manifests are registered there

BUILDROOT="$1"
SPEC="$2"

PRODUCT=nmh-transport
PRODUCTDIR=/opt/nmh-transport

. $(dirname $0)/common.sh

# Move all from temp_nmh/ to PRODUCTDIR/
move_dir "$PRODUCTDIR/temp_nmh" "$PRODUCTDIR"

awk '/^%dir/ {key=$0; gsub(/"/,"",key); gsub(/\/+$/,"",key); if (seen[key]++) next} {print}' "$SPEC" > "$SPEC.dedup" && mv "$SPEC.dedup" "$SPEC"
