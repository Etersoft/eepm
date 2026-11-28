#!/bin/sh

PKGNAME=10-strike-nmagent
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="10-Strike Network Monitor Pro agent (Linux monitoring service) from the official site"
URL="https://www.10-strike.ru/network-monitor/"

. $(dirname $0)/common.sh

# unversioned download link, the vendor keeps only the current build
warn_version_is_not_supported

PKGURL="https://10-strike.ru/network-monitor/pro/redos/nmagent-redos.tar.gz"

install_pack_pkgurl || exit

cat <<EOF

Note: run
# serv nmagentd on
to enable and start the agent service (it listens on port 45668, see /etc/sysconfig/nmagentd).
Run
# sensors-detect
once to configure hardware sensors monitoring.
EOF
