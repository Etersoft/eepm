#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"
PRODUCT=cisco-secure-client
PRODUCTDIR=/opt/cisco/secureclient
UNIREQUIRES="iptables ca-certificates xdg-utils libnm.so.0"

. "$(dirname "$0")/common.sh"

add_bin_exec_command cisco-secure-client "$PRODUCTDIR/bin/vpnui"
add_bin_exec_command anyconnect "$PRODUCTDIR/bin/vpnui"
add_bin_exec_command cisco-vpn "$PRODUCTDIR/bin/vpn"
add_conflicts cisco-anyconnect-vpn cisco-secure-client-vpn-cli

# Replace the useful part of vendor postinst with service-time initialization.
# Never execute vendor binaries or modify the host while repacking. Keep local
# administrator policy on upgrades, but refresh the manifest for the payload.
cat <<'INIT' | create_exec_file "$PRODUCTDIR/bin/epm-vpn-init"
#!/bin/sh
set -e
cd /opt/cisco/secureclient
if [ ! -s AnyConnectLocalPolicy.xml ]; then
    bin/acinstallhelper -acpolgen bd=false bdl=false rswd=false rhwd=false \
        rrwd=false rlwd=false fm=false rpc=false rtp=false rwl=false \
        sct=false efn=true upsu=true upcu=true upvp=true upmv=true \
        upip=true upsp=true upscr=true uphlp=true upres=true uploc=true \
        upal= rsc=false orc=false
fi
bin/manifesttool_vpn -i /opt/cisco/secureclient /opt/cisco/secureclient/ACManifestVPN.xml
INIT

cat <<'UNIT' | create_file /usr/lib/systemd/system/vpnagentd.service.d/epm-init.conf
[Service]
ExecStartPre=/opt/cisco/secureclient/bin/epm-vpn-init
UNIT

add_libs_requires
