#!/bin/sh -x

# Repack nmh-transport.rpm — Native Messaging Host for browsers (Saby plugin transport).
# Maintainer scripts replaced by:
#   - move temp_nmh/* into target dir
#   - package browser native messaging manifests instead of running nmh-registrator

BUILDROOT="$1"
SPEC="$2"

PRODUCT=nmh-transport
PRODUCTDIR=/opt/nmh-transport

. $(dirname $0)/common.sh

# Move all from temp_nmh/ to PRODUCTDIR/
move_dir "$PRODUCTDIR/temp_nmh" "$PRODUCTDIR"

# Package the native messaging manifests instead of running the vendor registrator.
# Yandex Browser and Chromium-Gost also look in /etc/chromium/native-messaging-hosts.
transport="$(for candidate in "$BUILDROOT$PRODUCTDIR"/*/service/nmh-transport ; do
    [ -f "$candidate" ] && [ -x "$candidate" ] && printf '%s\n' "$candidate"
done | sort -V | tail -n 1)"
[ -n "$transport" ] || fatal "Can't find executable Saby native messaging host"
transport="${transport#"$BUILDROOT"}"

for manifestdir in /etc/opt/chrome/native-messaging-hosts /etc/chromium/native-messaging-hosts ; do
    cat <<EOF | create_file "$manifestdir/ru.tensor.sbis_plugin_nmh.json"
{
    "name": "ru.tensor.sbis_plugin_nmh",
    "description": "Saby native messaging host",
    "path": "$transport",
    "type": "stdio",
    "allowed_origins": ["chrome-extension://pbcgcpeifkdjijdjambaakmhhpkfgoec/"]
}
EOF
done
for manifestdir in /usr/lib/mozilla/native-messaging-hosts /usr/lib64/mozilla/native-messaging-hosts ; do
    cat <<EOF | create_file "$manifestdir/ru.tensor.sbis_plugin_nmh.json"
{
    "name": "ru.tensor.sbis_plugin_nmh",
    "description": "Saby native messaging host",
    "path": "$transport",
    "type": "stdio",
    "allowed_extensions": ["sbis_plugin_nmh@tensor.ru"]
}
EOF
done

awk '/^%dir/ {key=$0; gsub(/"/,"",key); gsub(/\/+$/,"",key); if (seen[key]++) next} {print}' "$SPEC" > "$SPEC.dedup" && mv "$SPEC.dedup" "$SPEC"
