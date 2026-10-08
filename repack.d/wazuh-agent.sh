#!/bin/sh

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
ORIGPKG="$4"

PRODUCT=wazuh-agent
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# The vendor installs to /var/ossec, the binaries find their dir at runtime
move_to_opt /var/ossec || fatal

# fix hardcoded /var/ossec in the service files and text scripts
for f in usr/lib/systemd/system/wazuh-agent.service etc/rc.d/init.d/wazuh-agent \
         $(cd "$BUILDROOT" && grep -rIl '/var/ossec' .$PRODUCTDIR 2>/dev/null) ; do
    [ -f "$BUILDROOT/$f" ] || continue
    subst "s|/var/ossec|$PRODUCTDIR|g" "$BUILDROOT/$f"
done

ver="$(sed -n 's|^Version:[[:space:]]*||p' "$SPEC" | head -n1)"
genscript="$BUILDROOT$PRODUCTDIR/packages_files/agent_installation_scripts/gen_ossec.sh"

# The vendor %post (stripped by repack) generates these files at install time,
# but the spec %files still lists them, so reproduce them for rpmbuild.
mkdir -p "$BUILDROOT/etc" "$BUILDROOT$PRODUCTDIR/etc" "$BUILDROOT$PRODUCTDIR/logs"

# legacy version stamp
echo "VERSION=\"v$ver\"" > "$BUILDROOT/etc/ossec-init.conf"

# default agent config (the manager address is left as MANAGER_IP for the user)
if [ -f "$genscript" ] ; then
    ( cd "$(dirname "$genscript")" && sh ./gen_ossec.sh conf agent centos 7 $PRODUCTDIR ) \
        > "$BUILDROOT$PRODUCTDIR/etc/ossec.conf" 2>/dev/null
fi
[ -s "$BUILDROOT$PRODUCTDIR/etc/ossec.conf" ] || touch "$BUILDROOT$PRODUCTDIR/etc/ossec.conf"

# runtime log files
touch "$BUILDROOT$PRODUCTDIR/logs/active-responses.log" \
      "$BUILDROOT$PRODUCTDIR/logs/ossec.json" \
      "$BUILDROOT$PRODUCTDIR/logs/ossec.log"

# keep only static files in /opt: move logs and state to /var
move_dir $PRODUCTDIR/logs /var/log/$PRODUCT || fatal
move_dir $PRODUCTDIR/queue /var/lib/$PRODUCT/queue || fatal
move_dir $PRODUCTDIR/var /var/lib/$PRODUCT/var || fatal
pack_dir /var/lib/$PRODUCT
for i in logs:/var/log/$PRODUCT queue:/var/lib/$PRODUCT/queue var:/var/lib/$PRODUCT/var ; do
    ln -s ${i#*:} $BUILDROOT$PRODUCTDIR/${i%%:*} || fatal
    pack_file $PRODUCTDIR/${i%%:*}
done

# The vendor %pre (stripped by repack) creates wazuh user and group,
# agent-auth fails without them. The user is created by systemd-sysusers filetrigger
# after the files are installed, then systemd-tmpfiles filetrigger (runs after it)
# sets group wazuh and the vendor modes (lost by repack).
# Owner is always root: the vendor wazuh owned files get owner permissions for the group.
# See https://bugs.etersoft.ru/show_bug.cgi?id=19660
cat <<EOF | create_file /usr/lib/sysusers.d/wazuh-agent.conf
g wazuh -
u wazuh -:wazuh "Wazuh agent" $PRODUCTDIR /sbin/nologin
EOF

{
echo "z /var/lib/$PRODUCT 0750 root wazuh -"
a='' rpm -qp --qf '[%{FILEUSERNAME} %{FILEGROUPNAME} %{FILEMODES:octal} %{FILENAMES}\n]' "$ORIGPKG" | \
    awk '$1 == "root" && $2 == "root" { next }
         {
             m = substr($3, length($3) - 3)
             s = substr(m, 1, 1) ; u = substr(m, 2, 1) + 0 ; g = substr(m, 3, 1) + 0 ; o = substr(m, 4, 1)
             if ($1 != "root") for (b = 4; b >= 1; b /= 2) if (int(u / b) % 2 && !(int(g / b) % 2)) g += b
             print "z " $4 " " s u g o " root " $2 " -"
         }' | sed -e "s|^z /var/ossec/logs|z /var/log/$PRODUCT|" \
        -e "s|^z /var/ossec/queue|z /var/lib/$PRODUCT/queue|" \
        -e "s|^z /var/ossec/var|z /var/lib/$PRODUCT/var|" \
        -e "s|^z /var/ossec|z $PRODUCTDIR|"
} | create_file /usr/lib/tmpfiles.d/wazuh-agent.conf
