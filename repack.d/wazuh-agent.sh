#!/bin/sh

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

ver="$(sed -n 's|^Version:[[:space:]]*||p' "$SPEC" | head -n1)"
genscript="$BUILDROOT/var/ossec/packages_files/agent_installation_scripts/gen_ossec.sh"

# The vendor %post (stripped by repack) generates these files at install time,
# but the spec %files still lists them, so reproduce them for rpmbuild.
mkdir -p "$BUILDROOT/etc" "$BUILDROOT/var/ossec/etc" "$BUILDROOT/var/ossec/logs"

# legacy version stamp
echo "VERSION=\"v$ver\"" > "$BUILDROOT/etc/ossec-init.conf"

# default agent config (the manager address is left as MANAGER_IP for the user)
if [ -f "$genscript" ] ; then
    ( cd "$(dirname "$genscript")" && sh ./gen_ossec.sh conf agent centos 7 /var/ossec ) \
        > "$BUILDROOT/var/ossec/etc/ossec.conf" 2>/dev/null
fi
[ -s "$BUILDROOT/var/ossec/etc/ossec.conf" ] || touch "$BUILDROOT/var/ossec/etc/ossec.conf"

# runtime log files
touch "$BUILDROOT/var/ossec/logs/active-responses.log" \
      "$BUILDROOT/var/ossec/logs/ossec.json" \
      "$BUILDROOT/var/ossec/logs/ossec.log"
