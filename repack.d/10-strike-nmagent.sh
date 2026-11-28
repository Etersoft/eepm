#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/10-strike/netmonitor/agent

. $(dirname $0)/common.sh

# put service file to the normal place
move_file /lib/systemd/system/nmagentd.service /usr/lib/systemd/system/nmagentd.service

# The agent writes nmagent.ini and nmagent.log here
pack_dir /opt/10-strike/netmonitor/agent
pack_dir /opt/10-strike/netmonitor
pack_dir /opt/10-strike

# The agent runs these tools to collect monitoring data
# (sensors, smartctl, iostat, ping are required, lpstat is used for printers if cups is installed)
add_unirequires /usr/bin/sensors /usr/sbin/smartctl /usr/bin/iostat /usr/bin/ping

# uses system Qt5 (not bundled)
add_unirequires libQt5Core.so.5 libQt5Network.so.5 libQt5Xml.so.5
